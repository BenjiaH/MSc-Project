clear;
clc;
close all;

fileNameStr = 'FE_input.txt';
[fid, message] = fopen(fileNameStr, 'rb');
data1 = textscan(fid, '%d');
samplesPerCode = 99375;
% [data, count] = fread(fid);
data = data1{1};
histogram(data);
dmax = max(abs(data)) + 1;
axis tight;
adata = axis;
axis([-dmax dmax adata(3) adata(4)]);
grid on;
title ('Histogram'); 
xlabel('Bin'); ylabel('Number in bin');
%     H = hist(data, -8:8)

%     davg=std(abs(data))
% dmax = max(abs(data)) + 1;
% axis tight;
% adata = axis;
% axis([-dmax dmax adata(3) adata(4)]);
% grid on;
% title ('Histogram'); 
% xlabel('Bin'); ylabel('Number in bin');