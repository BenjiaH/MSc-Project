clear;
clc;
close all;

filename = '../../../Hardware Receiver/trackingChannelMasterSlave_18_3/trackingChannelMasterSlave_18_3.sim/sim_1/behav/modelsim/Is_and_Qs_signal.log';
% filename = 'Is_and_Qs_signal_bak/Is_and_Qs_signal_1000ms.log';
fileID = fopen(filename);
IQCell = textscan(fileID,'%f %f','Delimiter',',');
fclose(fileID);

IQ = [IQCell{:, 1}, IQCell{:, 2}];
squareEnergy = (IQ(:, 1) .^ 2 + IQ(:, 2) .^ 2);
figure(1);
plot((squareEnergy));
hold on;
averageNoise = 1.7e6;
note = sprintf("Average noise: %d", averageNoise);
yline(averageNoise, '-', note, LineWidth=1.5,FontSize=18);



% filename = 'Is_and_Qs_signal_bak/Is_and_Qs_signal_60ms.log';
% fileID = fopen(filename);
% IQCell = textscan(fileID,'%f %f','Delimiter',',');
% fclose(fileID);
% 
% IQ = [IQCell{:, 1}, IQCell{:, 2}];
% squareEnergy = (IQ(:, 1) .^ 2 + IQ(:, 2) .^ 2);
% figure(2);
% plot((squareEnergy));
% hold on;
% averageNoise = 1.7e6;
% note = sprintf("Average noise: %d", averageNoise);
% yline(averageNoise, '-', note, LineWidth=1.5,FontSize=18);