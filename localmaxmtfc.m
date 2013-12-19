function [maxinds] = localmaxmtfc(x,window)
%form:  [maxinds] = localmax(x,window)
%
%x is a vector
%This function computes a local maximum within a window +/- window.
%Only values within 10% of absolute max are considered

fractol=0.6;%change this if you want to change the fraction tolerance below absmax


absmax=max(x);
thr=absmax-(fractol*absmax);

y=thresholdb(x,thr);%this gives a binary vector with 1s above thr

%find groups of y==1
y1=y(1:length(y)-1);
y2=y(2:length(y));
ydiff=y2-y1;

f1=find(ydiff==1);%find when bout of 1s in y begins
g1=find(ydiff==-1);%find when bout of 1s in y ends



            
 
 %find groups of y==1
y1=y(1:length(y)-1);
y2=y(2:length(y));
ydiff=y2-y1;

f=find(ydiff==1);%find when bout of 1s in y begins
g=find(ydiff==-1);%find when bout of 1s in y ends

if ~isempty(f)
    if g(1)<f(1)
        f=[1; f];
    end;
end;

peakwins=[];
for i=1:length(f)
    on=f(i);
    h=find(g>on);
    if ~isempty(h)
    off=g(h(1));
    peakwins=[peakwins; on off 0 0];%zeros added for next step
    end;
end;



%find maxs in peakwins
for i=1:size(peakwins,1)
    t=x(peakwins(i,1):peakwins(i,2));
    lmax=max(t);
    f=find(t==lmax);
    if length(f)>1
        f=f(1);
    end;
    peakwins(i,3)=lmax;
    peakwins(i,4)=f+peakwins(i,1);%index relative to x vector
end;
    

%find peakwins that are within window
todel=[];
if size(peakwins,1)>=2
    rownum=size(peakwins,1)-1;
for i=2:rownum
    tprev=peakwins(i,1) - peakwins(i-1,2); %end of bout of 1s for previous
    tnext=peakwins(i+1,1) - peakwins(i,2);%front of bout of 1s for next
    if tprev<window
        mxprev=peakwins(i-1,3);
        mx=peakwins(i,3);
        if mx>mxprev
            todel=[todel; i-1];
            %peakwins(i-1,:)=[];
        else
            todel=[todel; i];
            %peakwins(i,:)=[];
        end;
    end;
     if tnext<window
        mxnext=peakwins(i+1,3);
        mx=peakwins(i,3);
        if mx>mxnext
            todel=[todel; i+1];
            %peakwins(i+1,:)=[];
        else
            todel=[todel; i];
            %peakwins(i,:)=[];
        end;
    end;
end;
peakwins(todel,:)=[];
end;

if ~isempty(peakwins)
%whatever peakwins are left, take indices
maxinds=peakwins(:,4);
else
    maxinds=[];
end;
    
