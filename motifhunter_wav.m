function [exem] = motifhunter_wav(exem,plt)
%form:  motifhunter_wav(exem,plt)
%
%THIS FUNCTION works with wav files - only vocalizations!!!
%
%Get exem from getexem.m
%NOTE: Changed Filtering sound at 2000-8000 Hz because of noise at ~1.9 kHz
%
%voconly added 8/6/08 TAN
%TAN 12/18/2013 cleaned up

%% set up

format compact
format short g

%you may need to lower/raise, depending on motif quality
qualitycontrol=12;%12 for o838-TAN 8/31/2011 lower to get more, lesser quality motifs.  raise to make motif crtiteria more stringent.


thisdir=cd;
anadir=thisdir;
peakcor=[];
offsets=[];
fs=44100;

%this pads the end with additional data that does not match exemplar
extraatend=0.5;%sec
extraatend=floor(extraatend*fs);%points


if ~exist('ext','var')
    ext='wav';  
end;
if ~exist('plt','var')
    plt=0;
end;


f=find(thisdir==filesep);
thisdir=thisdir(f(length(f)-1)+1:f(length(f))-1)



filenm=['mot' thisdir]
shortfilenm=['mot' thisdir];

if exist('exem')==0
    exem=getexem(anadir);
end;
if size(exem,1)>1
    exem=permute(exem,[2 1]);
end;



%% make filters

%make filter for making song amplitude envelope***************:
qorder=2048;
q=fir1(qorder,50/floor(fs/2));

%make bandpass filter for taking band of frequencies not covered by masking noise***************:
%1.0 should correspond to half the sample rate
lo=2000/floor(fs/2);
hi=8000/floor(fs/2);
bporder=256;
bp=fir1(bporder,[lo hi],'bandpass');

%% get files

dfiles=dir;
files=[];
tms=[];
for i=1:length(dfiles)
    f=findstr(dfiles(i).name,ext);
    if ~isempty(f)
        files=[files i];
    end;
end;


files=dfiles(files);

%randomize in case crashes due to low memory
[r] = randintwithoutreplace(length(files),[1 length(files)]);

files=files(r);

maxmotifs=100;

mtfs{3}=[];

%% preallocate data matrices

for i=1:2
    mtfs{i}=zeros(maxmotifs,length(exem)+extraatend+1);
end;

%% main for loop
count=0;
for j=1:length(files)
    
    if count<=maxmotifs
        fnt=files(j).name;
    if rem(j,10)==0
        fnt
        sprintf('%d %% done',round(size(mtfs{4},1)/size(mtfs{1},1)*100))
    end;

    sng = wavread(files(j).name);
    origsng=sng;

    %bandpass filter song
    ft=conv(sng,bp);
    ft=ft(bporder/2:length(ft)-bporder/2);
    song=abs(diff(ft));
    %low pass filter song
    xf=conv(song,q);
    xf2=xf(qorder/2:length(xf)-qorder/2);
    sng=xf2;
    sng=abs(sng);
    
    

    %cross-correlate with exemplar
    %sprintf('length(sng) = %d\n',length(sng))

            xc=xcorr(sng,exem);
            xc(1:length(origsng)+1)=[];
            
            if plt==1
                figure(1)
                clf
                subplot(3,1,1)
                plot(exem,'r')
                axis tight
                grid on
                subplot(3,1,2)
                plot(sng,'k')
                axis tight
                grid on
                subplot(3,1,3)
                plot(xc,'b')
                axis tight
                grid on
                input('hit enter\n')
            end;

            %**************uncomment if tweaking*************
          %   sprintf('maximum of the cross-correlation:')
          % max(xc)
            if max(xc)>qualitycontrol%this was experimentally determined for 'good' motif
                %if getting too many long calls (not motifs), lower maxxc
                maxxc=6e9;%xc higher than this are long calls
                [maxinds] = localmaxmtfc(xc,length(exem));

                if ~isempty(maxinds)
                     origsng=origsng';
                   % sprintf('~isempty maxinds')
                    for i=1:length(maxinds)
        %                     length(exem)
        %                     maxinds(i)+length(exem)
        %                     length(origsng)
                        if maxinds(i)+length(exem)+extraatend <= length(origsng)
                            %sprintf('**********************gothere')
                            %before save, need to screen for loud, short calls
                            test=sng(maxinds(i)+1:maxinds(i)+length(exem));
                            nexem=exem/max(exem);
                            ntest=test/max(test);
                            ntest=ntest';
                            differ=nexem-ntest;

        %                     mean(test)
        %                     figure
        %                     plot(test,'k')
        %                     axis tight
        %                     pause(3)

                            %may have to change threshold depending on acquisition
                            %rig
                            sound=thresholdb(test,0.005);%thr changed from 10 to 0.01 TAN 8/6/08
                            %changed sound threshold from 0.01 to 0.005 TAN 8/27/08
                            fracsound=sum(sound)/length(test)
                            plt2=0;
                            if plt2==1
                                origtest=origsng(maxinds(i):maxinds(i)+length(exem));

                                figure(20)
                                clf
                                plot(differ,'r')
                                %hold on
                                %plot(test,'k')
                                %axis tight
                                sum(abs(differ))
                                fracsound
                                figure(21)
                                specgram(origtest,[],44100)
                                input('Hit enter to move to next.')
                            end;
%                             sum(abs(differ))<differthr
%                             fracsound>=0.5
% 
%                             sum(abs(differ))


                           %if sum(abs(differ))<differthr && fracsound>=0.5 
                            if fracsound>=0.5 
                                   % sprintf('*************gothere2')
                                count=count+1
%                                 size(origsng)
%                                 maxinds(i)
%                                 maxinds(i)+length(exem)+extraatend
                                mtfs{1}(count,:)=origsng(maxinds(i):maxinds(i)+length(exem)+extraatend);
                                mtfs{2}(count,:)=sng(maxinds(i):maxinds(i)+length(exem)+extraatend);
                                mtfs{3}=strvcat(mtfs{3},fnt);%[mtfs{4}; fnt];
                               % save(filenm,'mtfs');
                                %mtfs
                                 %sprintf('found motifs')
                                % filenm
                            end;
                        end;
                    end;

    
                    %for optimizing motif finding for different data sets
                    plt3=0;
                    if plt3==1 && ~isempty(mtfs{1})
                        clf
                        subplot(3,1,1)
                        specgram(origsng,[],44100);
                        v=axis;
                        axis([v(1) v(2) 500 10000])
                        subplot(3,1,2)
                        %plot(origsng,'k')
                        plot(xc,'k')
                        axis tight
                        subplot(3,1,3)
                        plot(diff(xc),'k')
                        axis tight

                        input('Hit enter to move to next.')
                    end;
                end;
            end;
       end;
   % end;

end;

%% get rid of extra rows

z=sum(mtfs{1},2);
f=find(z==0);

if ~isempty(f)
    mtfs{1}(f,:)=[];
end;
save(filenm,'mtfs');


