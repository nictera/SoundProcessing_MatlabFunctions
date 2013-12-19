function [data] = thresholdbb(x, thr)
%form:  [data] = threshold(x, thr)
%
%gives vector of same length as data with 1s where thr is crossed
%thresholdb is specialized for sound, that doesn't need to be normalized or
%the absolute value obtained

%x = x - mean(x);
%data = abs(x);
data=x;
data  = floor(data./thr);
data(data<0)=0;
data  = ceil(data./(data + 1));
