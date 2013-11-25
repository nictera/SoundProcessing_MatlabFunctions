function waveditrev(filename)
%form: waveditrev(filename)
%
%example: waveditrev('3_August_12_2006_15_05_21.wav');
%
%This function loads a wave file (filename), asks the user to select the 'song' out of
%the wave file, gets the user to name the wave file, and then filters and saves the
%file in savedir.  Default savedir is current directory.
%made/modified TAN 8/17/06 from filtdatc,wavedit
%cleaned up TAN 11/25/13

%set sampling rate
fs=44100;


f=findstr(filename,'wav');
g=findstr(filename,'dat');
if ~isempty(f)
    [x,fs,nbits]=wavread(filename);
elseif ~isempty(g)%if not a wave file, assume dat file from custom National Instruments data acquisition software
    [a]=loaddatvi(filename);
    x=a(5,:);
else
    error('The filename must contain the extension wav or dat.')
end;

%plot unfiltered oscillogram
specgram(x,[],fs);
v=axis;
h = figure;
subplot(2,1,1)
plot(x)%plot the unfiltered waveform in blue
hold on

%make filter to filter song 500 to 10000 Hz (Hamming fixed impulse
%response)
order=256;
b=fir1(order,[500/(fs/2) 10000/(fs/2)]);
xf=conv(x,b);
xf2=xf(order/2:length(xf)-order/2-1);

%normalize to save to the wave file
song=xf2./max(abs(xf2));%normalize to max
song=song*0.999;

%plot filtered oscillogram
figure(h)
subplot(2,1,1)
plot(song,'r');%plot the filtered waveform in red
axis tight
%plot sonogram
subplot(2,1,2)
specgram(song,[],fs)%plot the sonogram of the filtered waveform
v=axis;
axis([v(1) v(2) 0 10000])

%get user to choose song and save
input('Using the magnifier tool, select the song on the red trace and hit enter.\n Note only the x axis matters.\n')

v=axis;
b=song(round(v(1)):round(v(2)));
nm=input('Enter the name of the song.\n Example: bu70b3\n','s');
rnm=[nm 'r.wav'];
nm=[nm 'f.wav'];

sprintf('Saving forward and reverse wave files.\n');
wavwrite(b,44100,16,nm);

r=reverse(b);
wavwrite(r,44100,16,rnm);

