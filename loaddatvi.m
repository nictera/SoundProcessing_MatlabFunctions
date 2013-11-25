function [a,headerdat] = loaddatvi(filename, datatype)
%form: [a,headerdat] = loaddatvi(filename, datatype)
%
%This function takes a dat file created by the NickLabMain.vi LabView
%virtual instrument and outputs a cellular array (a) and header information
%(headerdat).
%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% [d] = loaddat(filename, datatype)
%%
%% filename : string, name of target file
%% datatype : string, one of the following:
%%           raw (default), sounds, psth, spikes, isi, overlay
%%

if exist('datatype') ~= 1  datatype = 'playback'; 
end;

fid = fopen(filename,'r','ieee-be');

switch datatype
case 'noheader'
       [a,count1] = fread(fid,[5,inf],'int16');
        x=a;
case 'playback'    
   [a,count1] = fread(fid,4,'int16');
   %presound time (sec)
   pre = a(1);
   %trial time (sec)
   total=a(2);
   %Current cycle
   cycle=a(3);
   %Number of channels
   numchs=a(4);
   
   %get Actual Scan Rate (Scans/sec)
     [a,count1] = fread(fid,1,'int32');
        srate=a(1);
        srate=srate/100;
  
  %get Total Samples per channel
       [a,count1] = fread(fid,1,'uint32');
        samps=a(1);
  
  %for each channel, get name, high and low airange
  hilo=[];
  for i=1:numchs
      %get size of channel name
        [a,count1] = fread(fid,1,'int16');
        sizech=a(1);
      %get channel name
        [a,count1] = fread(fid,sizech*2,'schar');
                name0=a;
                name0=transpose(name0);
                name{i}=setstr(name0);
    
        [a,count1] = fread(fid,2,'int16');
                hilo=[hilo; a(1) a(2)];
   end;

headerdat{1}=[pre total cycle numchs srate];
headerdat{2}=name;
headerdat{3}=hilo;

%get raw sound and voltage data
%check to make sure last channel is the sound channel (ch 0)
lastch=name{numchs};
lastch=lastch(1,length(lastch));
if lastch~='0'
    error('Last channel is not the sound channel.')       
end;

%********************read the rest of the file******************************************
[a,count1]=fread(fid,[5,inf],'int16');
%**************************************************************************

case 'trig'
    [a,count1] = fread(fid,3,'int16');
   %presound time (sec)
   pretrig = a(1);
   %trial time (sec)
   posttrig=a(2);
   %trigger channel (by scanlist 0=ch1; 1=ch2; 2=ch3; 3=ch4; 4=microphone
   %based on scan order in measurement automation explorer)
   trigch=a(3);
   
              %Number of channels
            [a,count1] = fread(fid,1,'int16');
            numchs=a(1);


   %get Actual Scan Rate (Scans/sec)
     [a,count1] = fread(fid,1,'int32');
        srate=a(1);
        srate=srate/100;
  
        
  %get trigger level
       [a,count1] = fread(fid,1,'int32');
        triglev=a(1)/100;
  
  %for each channel, get name, high and low airange
  hilo=[];
  for i=1:numchs
      %get size of channel name
        [a,count1] = fread(fid,1,'int16');
        sizech=a(1);
      %get channel name
        [a,count1] = fread(fid,sizech*2,'schar');
                name0=a;
                name0=transpose(name0);
                name{i}=setstr(name0);
    
        [a,count1] = fread(fid,2,'int16');
                hilo=[hilo; a(1) a(2)];
   end;

headerdat{1}=[pretrig posttrig trigch numchs];
headerdat{2}=name;
headerdat{3}=hilo;

%get raw sound and voltage data
%check to make sure last channel is the sound channel (ch 0)
lastch=name{numchs};
lastch=lastch(1,length(lastch));
if lastch~='0'
    error('Last channel is not the sound channel.')       
end;

%********************read the rest of the file******************************************
[a,count1]=fread(fid,[5,inf],'int16');
%trig end
%**************************************************************************

case 'voltage'
    [a,count1] = fread(fid,5,'int16');
   %pulse controller setting (0-3) (e.g., 20 mV/V)
   pulseid = a(1);
   %prepulse time (ms)
   prepulse=a(2);
   %pulse duration (ms)
   pulsedur=a(3);
   %postpulse time (ms)
   postpulse=a(4);
   %number of steps
   stepnum=a(5);
   
   
   %start amplitude
     [a,count1] = fread(fid,1,'int32');
        startamp=a(1)/100;
  
  %step amplitude
       [a,count1] = fread(fid,1,'int32');
        stepamp=a(1)/100;
 
  
                  %Number of channels
            [a,count1] = fread(fid,1,'int16');
            numchs=a(1);


   %get Actual Scan Rate (Scans/sec)
     [a,count1] = fread(fid,1,'int32');
        srate=a(1);
        srate=srate/100;

        

      
    headerdat{1}=[pulseid prepulse pulsedur postpulse stepnum numchs];
    
  %for each channel, get name, high and low airange
  hilo=[];
  for i=1:numchs
      %get size of channel name
        [a,count1] = fread(fid,1,'int16');
        sizech=a(1);
      %get channel name
        [a,count1] = fread(fid,sizech*2,'schar');
                name0=a;
                name0=transpose(name0);
                name{i}=setstr(name0);
    
        [a,count1] = fread(fid,2,'int16');
                hilo=[hilo; a(1) a(2)];
   end;

headerdat{2}=name;
headerdat{3}=hilo;

%get raw sound and voltage data
%check to make sure last channel is the sound channel (ch 0)
lastch=name{numchs};
lastch=lastch(1,length(lastch));
if lastch~='0'
    error('Last channel is not the sound channel.')       
end;

%********************read the rest of the file******************************************
[a,count1]=fread(fid,[5,inf],'int16');
%end voltage
%**************************************************************************
end;
fclose(fid);

