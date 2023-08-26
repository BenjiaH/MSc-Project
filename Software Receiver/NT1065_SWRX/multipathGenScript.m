close all;clear all;
addpath include             % The software receiver functions

[multiSettings]  = initSettingsMultipath();

outputFilename = 'PRN4Mulitpath_Amp_0p5_Phase_0_60s.dat';

PRN = 4;
Doppler = 270;
multiPathAmp = 0.5;
multiPathPhaseRad = 0;
noiseAmp = 10;

generateCAcodeMultipath(outputFilename, PRN, Doppler, multiPathAmp, multiPathPhaseRad,noiseAmp, multiSettings);