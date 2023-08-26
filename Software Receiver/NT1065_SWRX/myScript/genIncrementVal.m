% increment = freq*(2^NCO_length)/sampling_freq
% clc;
clear;
close all;

dopplerFreq = 2.2e3;
carrFreq = 14.58e6;
searchFreq = 5e3;
codeFreq = 10.23e6;
samplingFreq = 99.375e6;
NCOLength = 32;

incrementVal = @(freq) freq * (2 ^ NCOLength) / samplingFreq;


carrIncrementVal = ceil(incrementVal(carrFreq + dopplerFreq));
codeIncrementVal = ceil(incrementVal(codeFreq - searchFreq));

carrIncrementHexVal = dec2hex(carrIncrementVal, 8);
codeIncrementHexVal = dec2hex(codeIncrementVal, 8);

disp(carrIncrementVal);
disp(carrIncrementHexVal);
disp(codeIncrementVal);
disp(codeIncrementHexVal);