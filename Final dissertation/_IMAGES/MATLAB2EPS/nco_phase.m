clc;
clear;
close all;

incrementVal = 4;
overFlow = 25;
loopCnt = 17;
accum = 0;
accumReg = zeros(1, loopCnt);
overFlowReg = zeros(1, loopCnt);
overFlowReg(overFlowReg == 0) = overFlow;

for i = 1 : loopCnt
    accum = accum + incrementVal;
    if accum >= overFlow
        accum = 0;
    end
    accumReg(i) = accum;
end

figure();
plot(accumReg, '-o', "LineWidth", 1.5);
hold on;
plot(overFlowReg, "LineWidth", 1.5);
% title("Phase Function");
grid on;
xlabel("Time");
ylabel("Phase");
legend("Phase function", "Overflow");
ylim([-1 30]);



