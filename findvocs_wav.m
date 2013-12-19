function findvocs_wav(checksndthr)
%form: findvocs_wav(checksndthr)
%
%example: findvocs_wav(1)
%
%This function finds all 'songs' in all wav files in directory.
%Key varible is sndthr (see line 28) which may need to be tweaked for each
%data set. Lower will give more data and potentially more non-songs. 
%Set checksndthr=1 if want to check sound threshold.
%This function assumes sampling rate 44100 Hz.
%
%TAN 1/23/08 - changed pad 0.5 to 0.05 sec; changed max space and songlen
%TAN 12/18/13 - cleaned up for posting


%% initialize

anadir=cd

format short g
format compact


%define sampling rate
fs=44100;

%define sound threshold - may vary wildly with microphone and recording
%environment
%%%%%%%User - you may have to change%%%%%%%%%%%%%%%%%%%%%
sndthr=1e-4;


%define maximum space allowable in a song in msec
space = 150;%was 200 
space = floor(space*44.1);

%define minimum length of song in msec
songlen=500;%was 500
songlen=floor(songlen*44.1);

songs{1}=[];
filenames=[];
numsongs=0;

mkdir('songwvsc')



if exist('checksndthr')==0
    checksndthr=0;
end;

if checksndthr==1
    h=figure;
end;


%% Design low-pass filter

%make filter for making song amplitude envelope***************:
qorder=2048;
q=fir1(qorder,50/(44100/2));%50

%% Design band-pass filter

%make bandpass filter for taking band of frequencies not covered by masking noise***************:
%1.0 should correspond to half the sample rate
lo=1000/floor(22050);%1000
hi=8000/floor(22050);%8000
bporder=256;
bp=fir1(bporder,[lo hi],'bandpass');

%****************************************


%% Get files
%find all wav files
dfiles=dir;
files=[];
for i=1:length(dfiles)
    if ~isempty(findstr(dfiles(i).name,'wav'))
        files=[files i];
    end;
end;
files=dfiles(files);

%randomly scramble files 
r=randintwithoutreplace(length(files),[1 length(files)]);
files=files(r);

%% Try to make faster for massive directories - new to findvocs_wavi.m

clear dfiles r

groupSize=1000;

groupNum=ceil(length(files)/groupSize);

save('filenames.mat','files','groupSize','groupNum');


%% Go through every file
filesongnum=[];

for j=1:groupNum
    
    load('filenames.mat','files')
    if j~=groupNum
        tfiles=files((j-1)*groupSize+1:j*groupSize);
    else
        tfiles=files((j-1)*groupSize+1:length(files));
    end;
    clear files
    
  
    sprintf(['************\n Percent done: ' num2str(j/groupNum*100) '\n************\n'])
   
    for i=1:length(tfiles)
        
        
        
        fn=tfiles(i).name
        %check to see if file has already been done (this is for restarts so
        %that don't waste time reanalyzing) TAN 04/14/2011
        donefn=['songwvsc' filesep fn(1:length(fn)-4) '*'];
        alreadyDone=FindFiles(donefn);
        if isempty(alreadyDone)
            wv=wavread(fn);
            filesongnumt=1;
            %change to row vector if column
            if size(wv,1)>11
                wv=wv';
            end;
            
            
            %% convert the song{cnt} to an amplitude envelope
            
            x=abs(wv);
            %bandpass filter song
            ft=conv(x,bp);
            ft=ft(bporder/2:length(ft)-bporder/2);
            x=abs(diff(ft));
            
            %low pass filter song
            xf=conv(x,q);
            xf2=xf(qorder/2:length(xf)-qorder/2);
            sng=xf2;%abs(xf2);
            
            allvoc=sng;
            sound=thresholdbb(allvoc,sndthr);
            snd=wv;
            
            %% find songs (>=songlen msec sound with less than space msec space)
            
            mindur=floor(15*44.1);
            mindur2=floor(20*44.1);
            minvoid=space;
            tvoc=[];
            [tvoc] = binthreshh(sound,0.9,0.9,mindur,mindur2,minvoid);
            %tvoc is 2-column #voc-row matrix. Column 1 is beginning of voc,
            %Col 2 is end of voc.
            
            %size(tvoc)
            if ~isempty(tvoc)
                %sprintf('There are vocalizations.')
                vend=tvoc(1:size(tvoc,1)-1,2);
                vbeg=tvoc(2:size(tvoc,1),1);
                vspace=vbeg-vend;
                voc1=tvoc(1,1);
                tvoct=[];
                %if songs==1
                %****look for spaces between tvocs. If less than minspace, combine.
                f=find(vspace<=space);%f denotes the syllable in front of the space
                for k=1:size(tvoc,1)
                    g=find(f==k);
                    if k==size(tvoc,1)%if it's the last syllable
                        tvoct=[tvoct; voc1 tvoc(k,2)];
                    elseif isempty(g)%if the space was larger than minspace
                        tvoct=[tvoct; voc1 tvoc(k,2)];
                        voc1=tvoc(k+1,1);
                        %else do nothing, go to next syllable
                    end;
                end;
                
            else
                % sprintf('I didn"t find any vocalizations (tvoc is empty).')
                
            end;
            %end;
            %end;
            tvoc=tvoct;
            %if ~isempty(tvoc)
            if size(tvoc,1)>=2%if there are at least 2 vocalizations - changed from above 031406 by TAN
                
                % sprintf('There are at least 2 vocalizations.')
                
                %****cut out the song plus silence padding on each side
                pad = 0.0500;%pad in seconds%changed 031406 by TAN (was 0.1 sec)
                %convert pad to points
                pad=pad*44100;
                
                %cd(ad)
                %look for songs *********************************************************
                tvoctodel=[];
                saveinter=0;
                inter=[];
                saved=0;
                for k=1:size(tvoc,1)
                    tbeg=tvoc(k,1);
                    ted=tvoc(k,2);
                    voclen=ted-tbeg;
                    
                    if voclen>songlen
                        savesong=1;
                        saveother=0;
                        numsongs=numsongs+1
                    else
                        % sprintf('... but the vocalization is not long enough (decrease songlen if necessary).')
                        savesong=0;
                        saveother=1;
                    end;
                    
                    if tvoc(k,1)-pad<=0
                        beg=1;
                    else beg=tvoc(k,1)-pad;
                    end;
                    if tvoc(k,2)+pad>length(snd)
                        ed=length(snd);
                    else ed=tvoc(k,2)+pad;
                    end;
                    
                    if savesong==1
                        sprintf('Trying to save song.')
                        w=wv(beg:ed);
                        %                 songs{numsongs}=v;
                        %                 filesongnum=[filesongnum; filesongnumt];
                        %                 if numsongs==1
                        %                     filenames=fn;
                        %                 else
                        %                     filenames = strvcat(fn,filenames);
                        %                 end;
                        %                 save songdat songs filenames numsongs filesongnum
                        ft=fn;
                        f=findstr(ft,'wav');
                        ft=ft(1:f(1)-2)
                        fnt=['songwvsc/' ft '_' num2str(filesongnumt) '.wav']
                        noclipwavwrite(w,fnt);
                        filesongnumt=filesongnumt+1;
                        
                    end;
                end;
            end;
            
            
            %% CHECK sound threshold
            if checksndthr==1
                figure(h)
                clf
                subplot(3,1,1)
                specgram(wv,[],44100)
                v=axis;
                axis([v(1) v(2) 0 10000])
                subplot(3,1,2)
                plot(allvoc,'r')
                axis tight
                subplot(3,1,3)
                plot(sound,'k')
                axis tight
                v=axis;
                axis([v(1) v(2) 0 1.1])
                input('If there is a song in top panel and nothing in bottom panel, you need to lower the sound threshold.\n Use the middle panel as your guide.\n Hit enter to continue.\n')
            end;
            
        else sprintf('Skipping. %s done.\n',donefn)
        end;
        
        
    end;
end;
    
    
