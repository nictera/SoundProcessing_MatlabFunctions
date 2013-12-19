function [data] = thresholdb(x, thr)
%form:  [data] = threshold(x, thr)
%
%gives vector of same length as data with 1s where thr is crossed

%data = x - mean(x(:))
%data = abs(x);
data  = floor(x./thr);
data(data<0)=0;
data  = ceil(data./(data + 1));
