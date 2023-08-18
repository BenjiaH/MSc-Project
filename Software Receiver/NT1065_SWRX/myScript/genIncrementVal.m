% increment = freq*(2^NCO_length)/sampling_freq
% clc;
clear;
close all;

dopplerFreq = -2.2e3;
carrFreq = 14.58e6;
searchFreq = 5e3;
codeFreq = 10.23e6;
samplingFreq = 99.375e6;
NCOLength = 32;

incrementVal = @(freq) freq * (2 ^ NCOLength) / samplingFreq;

carrIncrementVal = dec2hex(ceil(incrementVal(carrFreq + dopplerFreq)), 8);
codeIncrementVal = dec2hex(ceil(incrementVal(codeFreq - searchFreq)), 8);

disp(carrIncrementVal);
disp(codeIncrementVal);