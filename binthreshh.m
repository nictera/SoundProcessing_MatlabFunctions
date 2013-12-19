function [newind] = binthreshg(vec,hithr,lothr,mindur,mindur2,fracspace)
%form:  [binind] = binthreshb(binvec,mindur,fracspace)
%
%example:  [binind] = binthreshb(voc,500,.5)
%
%This function finds a series of ones in a binary vector with a minimum
%duration in points of mindur and a fractional zero tolerance of the
%fraction fracspace.

%convert mindur (in msec) to points (assume decimate by 2)
%mindur=mindur*floor(22.05/2);


      plt=0;


vocalcraptrial=0;

        hibin=thresholdb(vec,hithr);
        lobin=thresholdb(vec,lothr);


b=hibin;
binvec=hibin;

if exist('fracspace')==0
    fracspace=0; %no space
end;

b1=b(1:length(binvec)-1);
b2=b(2:length(binvec));
bdiff=b1-b2;


%find when sequence [0 1]
f=find(bdiff==-1);

%need to include first point if song ongoing when trial starts
%if b(1)==1 & ~isempty(f)
 %   f=[1;f];
%end;

if ~isempty(f)
binind=[];
for i=1:length(f)
    if f(i)+mindur<=length(b)
        s=sum(b(f(i):f(i)+mindur));
        minlen=mindur;
    else
        s=sum(b(f(i):length(b)));
        minlen=length(b)-f(i);
    end;

    if s>=minlen-round(minlen*fracspace)
        %continue looking to get entire event - control for if at end of
        %trial
        test=b(f(i)+minlen:length(b));
        g=find(test==0);
        if isempty(g)
            term=0;
        else
        term=min(g)-1;
        end;
       
            binind=[binind; f(i) f(i)+minlen+term];
    end;
end;
else binind=[];
end;


%clean up binind (get rid of duplicates)
todel=[];
if size(binind,1)>1
for i=1:size(binind,1)-1
    f=find(binind(i,2)==binind(:,2));
    if length(f)>1
        todel=[todel; f(2:length(f))];
    end;
end;
end;

        binind(todel,:)=[];
     
     
        
      if plt==1
        figure(1)
        clf
       subplot(2,1,1)
        plot(binvec)
       subplot(2,1,2)
       plot(lobin)
      end;
        
%Now get entire vocalization 
    %know from plotting exp data that good threshold to get above main
    %baseline but still get most of vocalization is 0.02
    

voc01=lobin;
    
            newind=[];

for i=1:size(binind,1)
   %get beginning of song
   front=voc01(1:binind(i,1));
   f=find(front==0);
   if isempty(f)
       beg=1;
   else
   beg=f(length(f))+1;
   end;
   %get ending of song
   back=voc01(binind(i,2):length(voc01));
   f=find(back==0);
   if isempty(f)
       ed=length(voc01);
   else
        ed=binind(i,2) + f(1) - 1;
   end;
   
   s=sum(voc01(beg:ed));
  % minlen2-round(minlen2*fracspace)
   minlen2=mindur2;
       if s>=minlen2-round(minlen2*fracspace)
           newind=[newind; beg ed];
       end;


%clean up newind (get rid of duplicates)
todel=[];
if size(newind,1)>1
for i=1:size(newind,1)-1
    f=find(newind(i,2)==newind(:,2));
    if length(f)>1
        todel=[todel; f(2:length(f))];
    end;
    f=find(newind(i,1)==newind(:,1));
    if length(f)>1
        todel=[todel; f(2:length(f))];
    end;
end;
end;

        newind(todel,:)=[];

end;

    
    
