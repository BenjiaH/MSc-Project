close all;clear all;
addpath include             % The software receiver functions

[signalSettings]  = initSettingsSignal();

outputFilename = 'test';

PRN = 4;
Doppler = 270;
noiseAmp = 10;

generateCAcodeComplex(outputFilename, PRN, Doppler, noiseAmp, signalSettings);