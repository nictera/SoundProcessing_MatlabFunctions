function noclipwavwrite(x,filename,shrink)
%form: noclipwavwrite(x,filename,shrink)
%
%example:  noclipwavwrite(longkhz4,'longkhz4.wav',0.9)
%

x=x/max(abs(x));
x=x*0.9999;

if exist('shrink')==1
    x=x*shrink;
end;

wavwrite(x,44100,16,filename);
