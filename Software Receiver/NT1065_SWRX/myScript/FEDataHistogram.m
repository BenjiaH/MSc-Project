clear;
clc;
close all;

fileNameStr = '../../../Hardware Receiver/trackingChannelMasterSlave_18_3/trackingChannelMasterSlave_18_3.sim/sim_1/behav/modelsim/FE_input.txt';
[fid, message] = fopen(fileNameStr, 'rb');
data1 = textscan(fid, '%d');
samplesPerCode = 99375;
[data, count] = fread(fid);
histogram(data1{1})
%     H = hist(data, -8:8)

%     davg=std(abs(data))
% dmax = max(abs(data)) + 1;
% axis tight;
% adata = axis;
% axis([-dmax dmax adata(3) adata(4)]);
% grid on;
% title ('Histogram'); 
% xlabel('Bin'); ylabel('Number in bin');