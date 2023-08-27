clear;
clc;
close all;

% filename = '../../../Hardware Receiver/trackingChannelMasterSlave_18_3/trackingChannelMasterSlave_18_3.sim/sim_1/behav/modelsim/Is_and_Qs_signal.log';
filename = 'Is_and_Qs_signal_bak/revised_Is_and_Qs_signal_2001ms_46250.log';
fileID = fopen(filename);
IQCell = textscan(fileID,'%f %f','Delimiter',',');
fclose(fileID);

IPhase = [IQCell{:, 1}];
QPhase = [IQCell{:, 2}];
IPhase = IPhase(1:50);
QPhase = QPhase(1:50);
squareEnergy = (IPhase .^ 2 + QPhase .^ 2);
n = ((squareEnergy));

figure(1);
subplot(3, 1, 1);
plot(IPhase);
title("I Phase");
xlabel("Time (ms)");
ylabel("Amplitude");
subplot(3, 1, 2);
plot(QPhase);
title("Q Phase");
xlabel("Time (ms)");
ylabel("Amplitude");
subplot(3, 1, 3);
plot(n);
title("Sum of square");
xlabel("Time (ms)");
ylabel("Amplitude");
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