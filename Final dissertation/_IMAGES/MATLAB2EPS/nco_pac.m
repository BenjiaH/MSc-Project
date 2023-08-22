clc;
clear;
close all;

phaseMax = 10;
highResolutionIndex  = 0 : 0.01 : phaseMax;
lowResolutionIndex = 0 : 1 : phaseMax;

highResolutionCos = cos(highResolutionIndex);
lowResolutionCos = cos(lowResolutionIndex);

figure(1);
plot(highResolutionIndex, highResolutionCos, LineWidth=1.5);
hold on;
plot(lowResolutionIndex, lowResolutionCos, 'o-' , LineWidth=1.5);
% title("Phase-to-Amplitude Function");
xlabel("Phase");
ylabel("Amplitude");
grid on;
legend("High resolution cosine wave", "Low resolution cosine wave");
ylim([-1.1 1.5]);
