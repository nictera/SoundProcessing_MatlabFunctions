function [rs] = reverse (song)
%
% [rs] = reverse(song)
%    reverse a song
%
%IN: song = data file to be time reversed
%OUT: rs = reversed verson of song
%
% written by Anthony Leonardo
%

n = length(song);
rs = zeros(1,n);
for i = 1:n
   rs(n-i+1) = song(i);
end;
