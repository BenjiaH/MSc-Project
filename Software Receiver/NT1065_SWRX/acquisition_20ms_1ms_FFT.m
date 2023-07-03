function acqResults = acquisition_20ms_1ms_FFT(longSignal, settings)
%Function performs cold start acquisition on the collected "data". It
%searches for GPS signals of all satellites, which are listed in field
%"acqSatelliteList" in the settings structure. Function saves code phase
%and frequency of the detected signals in the "acqResults" structure.
%
%acqResults = acquisition(longSignal, settings)
%
%   Inputs:
%       longSignal    - 11 ms of raw signal from the front-end 
%       settings      - Receiver settings. Provides information about
%                       sampling and intermediate frequencies and other
%                       parameters including the list of the satellites to
%                       be acquired.
%   Outputs:
%       acqResults    - Function saves code phases and frequencies of the 
%                       detected signals in the "acqResults" structure. The
%                       field "carrFreq" is set to 0 if the signal is not
%                       detected for the given PRN number. 
 
%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis and Dennis M. Akos
% Written by Darius Plausinaitis and Dennis M. Akos
% Based on Peter Rinder and Nicolaj Bertelsen
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------

%CVS record:
%$Id: acquisition.m,v 1.1.2.12 2006/08/14 12:08:03 dpl Exp $

%% Initialization =========================================================

% Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
                        (settings.codeFreqBasis / settings.codeLength));
                    
intTime_ms = 20;
% number of branches
numberOfBranches = 20; 
% Create one longSignal big enough for coherent accumulation with 20 branches 
signalLength_ms = (intTime_ms + numberOfBranches);

signal1 = longSignal(1 : signalLength_ms*samplesPerCode);
% signal0DC = signal1 - mean(signal1); 

% Find sampling period
ts = 1 / settings.samplingFreq;

% Find phase points of the local carrier wave 
phasePoints = (0 : (signalLength_ms*samplesPerCode-1)) * 2 * pi * ts;

% Number of the frequency bins for the given acquisition band (25Hz steps)
numberOfFrqBins = round(settings.acqSearchBand * intTime_ms * 2) + 1

% frequency step
freqStep = (1e3*settings.acqSearchBand)/(numberOfFrqBins-1) 

% Generate all C/A codes and sample them according to the sampling freq.
caCodesTable = makeCaTable(settings);


%--- Initialize arrays to speed up the code -------------------------------
% Search results of all frequency bins and code shifts (for one satellite)
results     = zeros(numberOfFrqBins, samplesPerCode);

% structure for coherent sums
coherentSums  = zeros(numberOfBranches, samplesPerCode);
% coherent results across frequency bins
resultsCoherent = zeros(numberOfFrqBins, samplesPerCode);
% branch results across frequency bins
branchResults = zeros(1,numberOfFrqBins);

% Carrier frequencies of the frequency bins
frqBins     = zeros(1, numberOfFrqBins);


%--- Initialize acqResults ------------------------------------------------
% Carrier frequencies of detected signals
acqResults.carrFreq     = zeros(1, 32);
% C/A code phases of detected signals
acqResults.codePhase    = zeros(1, 32);
% Correlation peak ratios of the detected signals
acqResults.peakMetric   = zeros(1, 32);
% noise floor values for SNR estimation
acqResults.noiseValue = 0;
%---- initialise counter for noise floor values to zero
NoiseNum = 0;
% intialise noise monitors
TempNoiseValue = zeros(1,numberOfFrqBins);
noiseValue = zeros(1, 32);

fprintf('(');

% Perform search for all listed PRN numbers ...
for PRN = settings.acqSatelliteList

%% Correlate signals ======================================================   
    %--- Perform DFT of C/A code ------------------------------------------
    caCode= caCodesTable(PRN, :);
    caCode1msFreqDom = conj(fft(caCode));
    
    %--- Make the correlation for whole frequency band (for all freq. bins)
    for frqBinIndex = 1:numberOfFrqBins
        frqBinIndex
        acqRes = zeros(signalLength_ms,samplesPerCode);

        for timeIndex = 1:signalLength_ms

            %--- Generate carrier wave frequency grid  -----------
            frqBins(frqBinIndex) = settings.IF - ...
                                   (settings.acqSearchBand/2) * 1000 + ...
                                   freqStep * (frqBinIndex - 1);

            %--- Generate local sine and cosine -------------------------------
            sinCarr = sin(frqBins(frqBinIndex) * phasePoints(((timeIndex-1)*samplesPerCode)+1:timeIndex*samplesPerCode));
            cosCarr = cos(frqBins(frqBinIndex) * phasePoints(((timeIndex-1)*samplesPerCode)+1:timeIndex*samplesPerCode));

            %--- "Remove carrier" from the signal -----------------------------
            I1      = sinCarr .* signal1(((timeIndex-1)*samplesPerCode)+1:timeIndex*samplesPerCode);
            Q1      = cosCarr .* signal1(((timeIndex-1)*samplesPerCode)+1:timeIndex*samplesPerCode);
      
            %--- Convert the baseband signal to frequency domain --------------
            IQfreqDom1 = fft(I1 + j*Q1);

            %--- Multiplication in the frequency domain (correlation in time
            %domain)
            convCodeIQ1 = IQfreqDom1 .* caCode1msFreqDom;

            %--- Perform inverse DFT and store correlation results ------------
            acqRes(timeIndex,:) =  ifft(convCodeIQ1);
        end
        % non-coherent sum
        results(frqBinIndex, :) = sum(abs(acqRes)).^ 2;
        % coherent sum
        for i = 1:20
            coherentSums(i, :) = sum(acqRes(i: i+intTime_ms,:));
        end
%          coherentSums(1, :) = sum(acqRes(1: intTime_ms,:));
%          coherentSums(2, :) = sum(acqRes(11: intTime_ms+10,:));
        % find the maximum
        [branchPeakSize, branchBinIndex] = max(max(coherentSums, [], 2));
        % square the result
        resultsCoherent(frqBinIndex, :) =  abs(coherentSums(branchBinIndex, :)).^2;   
        % record the branch
        branchResults(frqBinIndex)=branchBinIndex;
                
    end % frqBinIndex = 1:numberOfFrqBins
   
    
    %--- Plot FFTs of the signal acquistions if plotFFTs is high ---------
    if settings.plotFFTs == 1
        
        yrange = linspace(- freqStep*(numberOfFrqBins/2),freqStep*(numberOfFrqBins/2),numberOfFrqBins);
        xrange = linspace(-settings.codeLength/2,settings.codeLength/2,samplesPerCode);
        
        figure(PRN)
        surf(xrange,yrange,resultsCoherent);
        shading INTERP;
         
        title ('Acquisition results');
        xlabel('Code delay (chips)');
        ylabel('Frequency offset (Hz)');
        
    end %if

    
%% Look for correlation peaks in the results ==============================
    % Find the highest peak and compare it to the second highest peak
    % The second peak is chosen not closer than 1 chip to the highest peak
    
    %--- Find the correlation peak and the carrier frequency --------------
    [peakSize, frequencyBinIndex] = max(max(resultsCoherent, [], 2));

    %--- Find code phase of the same correlation peak ---------------------
    [peakSize, codePhase] = max(max(resultsCoherent));

    %--- Find 1 chip wide C/A code phase exclude range around the peak ----
    samplesPerCodeChip   = round(settings.samplingFreq / settings.codeFreqBasis);
    excludeRangeIndex1 = codePhase - samplesPerCodeChip;
    excludeRangeIndex2 = codePhase + samplesPerCodeChip;

    %--- Correct C/A code phase exclude range if the range includes array
    %boundaries
    if excludeRangeIndex1 < 2
        codePhaseRange = excludeRangeIndex2 : ...
                         (samplesPerCode + excludeRangeIndex1);
                         
    elseif excludeRangeIndex2 >= samplesPerCode
        codePhaseRange = (excludeRangeIndex2 - samplesPerCode) : ...
                         excludeRangeIndex1;
    else
        codePhaseRange = [1:excludeRangeIndex1, ...
                          excludeRangeIndex2 : samplesPerCode];
    end

    %--- Find the second highest correlation peak in the same freq. bin ---
    secondPeakSize = max(results(frequencyBinIndex, codePhaseRange));

    %--- Store result -----------------------------------------------------
    acqResults.peakMetric(PRN) = peakSize/secondPeakSize;
    
    % If the result is above threshold, then there is a signal ...
    if (peakSize/secondPeakSize) > settings.acqThreshold
        
        %--- Indicate PRN number of the detected signal -------------------
        fprintf('%02d ', PRN);
        
        %--- Save properties of the detected satellite signal -------------
        acqResults.carrFreq(PRN)  = frqBins(frequencyBinIndex);
        acqResults.codePhase(PRN) = codePhase;
        acqResults.bitBranch(PRN)  = branchResults(frequencyBinIndex);
        
    
    else
        %--- No signal with this PRN --------------------------------------
        fprintf('. ');
            
    end   % if (peakSize/secondPeakSize) > settings.acqThreshold
    

    
end    % for PRN = satelliteList


   
%=== Acquisition is over ==================================================
fprintf(')\n');
