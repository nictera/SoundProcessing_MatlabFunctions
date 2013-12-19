function [exem] = getexemb_wavc(anadir)
%

% thisdir=cd;
% f=find(thisdir==filesep);
% thisdir=thisdir(f(length(f))+1:length(thisdir));
% %f=find(thisdir=='_');
% %thisdir=thisdir(1:f(1)-1);
% %get rid of sng
% %thisdir=thisdir(4:length(thisdir));
% %dirname=['c:\anasong\' 'mtf' thisdir];
% % f=find(thisdir=='_');
% % thisdir=thisdir(1:f(1)-1)
% 
% %anadir=['/volumes/otis/users/teresanick/motifana'];
% %anadir=['K:\SleepDepAnalysis\CD041\motifana'];
% %anadir='g:/motifs';
% anadir='/volumes/otis_data3/PNN_R01/mtfs/';

Fs=44100;
%    hsw=spectrum.welch;


if exist('ext')==0
    ext='wav';
end;

%load baserms

%make filter for making song amplitude envelope***************:
qorder=2048;
q=fir1(qorder,50/(44100/2));
%   qe=fir1(qorder,50/(44100/2));

%make bandpass filter for taking band of frequencies not covered by masking noise***************:
%1.0 should correspond to half the sample rate
lo=1000/floor(22050);
hi=8000/floor(22050);
bporder=256;
bp=fir1(bporder,[lo hi],'bandpass');

%************************************************************************************************


dfiles=dir;

files=[];
for i=1:length(dfiles)
    f=findstr(dfiles(i).name,ext);
    if ~isempty(f)
        files=[i files];%want files to count down
    end;
end;



files=dfiles(files);


figure
h=gcf;

alto=0;

length(files)

for j=1:length(files)
    if alto==0
        files(j).name
        if rem(j,10)==0
            sprintf('%d %% done',round(100*i/length(files)))
        end;
        sng = wavread(files(j).name);

        %  fnt=files(j).name;


        figure(h)
        clf

        %plot spectrogram of sound
        subplot(2,1,1)
        specgram(sng,[],44100)
        v=axis;
        axis([v(1) v(2) 300 10000]);

        %plot oscillogram of sound
        subplot(2,1,2)
        plot(diff(sng),'k');
        axis tight
        v=axis;
        origax=axis;
        % axis off


        chews = input('Enter "y" if this contains a MOTIF, else just hit enter to move to the next file.\n','s');

        used=[];

        if chews=='y'
            % cd(dirname)

            subplot(2,1,2)

            % newax = input('Enter "y" if you need to PICK a motif, else just hit enter to move to the next sound.\n','s');

            % if newax=='y'
            stop=0;
            for j=1:10
                if alto==0
                    figure(h)

                    subplot(2,1,2)
                    axis auto
                    axis tight

                    if stop==0
                        oops='g';
                        keep=[];
                        keep=input('Hit enter after you have picked the motif in the oscillogram window.\n Enter "0" if you changed your mind.');

                        if isempty(keep)
                            subplot(2,1,2)
                            v=axis;
                            if v==origax
                                sprintf('You must pick the motif in the middle panel (song oscillogram).\n Try again.\n Hit enter after you have picked the motif.\n')
                                oops=='s';
                            end;
                            v=axis;
                            callst=ceil(v(1))
                            called=floor(v(2))

                            if ~isempty(used)
                                for k=1:size(used,1)
                                    if oops~='s'
                                        if (v(1)>=used(k,1) & v(1)<=used(k,2)) | (v(2)>=used(k,1) & v(2)<=used(k,2))
                                            oops=input('You already picked this one. Hit enter after you have picked the motif or enter "s" to move to next trial.\n','s')
                                        end;
                                    end;
                                end;
                            end;

                            oops
                            if oops~='s'


                                exem=sng(callst:called);
                                size(exem)
                                unfiltexem=exem;

                                alto=1;


                            end;
                        end;
                    end;


                end;



            end;
            % cd ..
        end;
    end;
end;






%***********************convert exem to filtered version

%bandpass filter song
ft=conv(exem,bp);
ft=ft(bporder/2:length(ft)-bporder/2);
song=abs(diff(ft));
%low pass filter song
xf=conv(song,q);
xf2=xf(qorder/2:length(xf)-qorder/2);
sng=xf2;
sng=abs(sng);
exem=sng;

%fn=[anadir filesep thisdir 'exem'];
fn=[anadir filesep 'exem'];

save(fn,'exem','unfiltexem')
