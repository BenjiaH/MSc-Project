clc;
clear;
close all;

u0 = zeros(1, 9);
u1 = ones(1, 5);
u2 = zeros(1, 9);
u3 = ones(1, 6);
u4 = zeros(1, 20);

squareSignal = [u0, u1 , u2, u3, u4];
copySquareSignal = circshift(squareSignal, 9);
[ac, aclags] = xcorr(squareSignal, squareSignal);
[cc, cclags] = xcorr(squareSignal, copySquareSignal);

%% Auto-correlation plot
% Creat plot
figure(1);

subplot(3, 2, 1);
plot(squareSignal, LineWidth=1.5);
grid on;
ylim([0 1.1]);
xlabel("Time");
ylabel("Amplitude");
title("Original signal")

subplot(3, 2, 3);
plot(squareSignal, LineWidth=1.5);
grid on;
ylim([0 1.1]);
xlabel("Time");
ylabel("Amplitude");
title("Original signal");

subplot(3, 2, 5);
stem(aclags, ac);
grid on;
xlabel("Shift");
ylabel("Amplitude");
title("Auto-correlation")

%% Cross-correlation plot
subplot(3, 2, 2);
plot(squareSignal, LineWidth=1.5);
grid on;
ylim([0 1.1]);
xlabel("Time");
ylabel("Amplitude");
title("Original signal")

subplot(3, 2, 4);
plot(copySquareSignal, LineWidth=1.5);
grid on;
ylim([0 1.1]);
xlabel("Time");
ylabel("Amplitude");
title("Delayed signal");

subplot(3, 2, 6);
stem(cclags, cc);
grid on;
xlabel("Shift");
ylabel("Amplitude");
title("Cross-correlation")
