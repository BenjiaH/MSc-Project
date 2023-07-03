function [pseudorangesL1, pseudorangesL5] = calculatePseudorangesL1andL5(trackResults, L5data, ...
                                                msOfTheSignal, ...
                                                channelList, settings)
%calculatePseudoranges finds relative pseudoranges for all satellites
%listed in CHANNELLIST at the specified millisecond of the processed
%signal. The pseudoranges contain unknown receiver clock offset. It can be
%found by the least squares position search procedure. 
%
%[pseudoranges] = calculatePseudoranges(trackResults, msOfTheSignal, ...
%                                       channelList, settings)
%
%   Inputs:
%       trackResults    - output from the tracking function
%       msOfTheSignal   - pseudorange measurement point (millisecond) in
%                       the trackResults structure
%       channelList     - list of channels to be processed
%       settings        - receiver settings
%
%   Outputs:
%       pseudoranges    - relative pseudoranges to the satellites. 

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis
% Written by Darius Plausinaitis
% Based on Peter Rinder and Nicolaj Bertelsen
%--------------------------------------------------------------------------
%
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

% CVS record:
% $Id: calculatePseudoranges.m,v 1.1.2.18 2006/08/09 17:20:11 dpl Exp $

%--- Set initial travel time to infinity ----------------------------------
% Later in the code a shortest pseudorange will be selected. Therefore
% pseudoranges from non-tracking channels must be the longest - e.g.
% infinite. 

%% change this to L5 tracking results file 

%% calculate pseudoranges

travelTimeL1 = inf(1, settings.numberOfChannels);

travelTimeL5 = inf(1, L5data.settings.numberOfChannels);
% Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
                        (settings.codeFreqBasis / settings.codeLength));
samplesPerChip = settings.samplingFreq /(settings.codeFreqBasis);
% Find number of samples per spreading code
samplesPerCodeL5 = round(L5data.settings.samplingFreq / ...
                        (L5data.settings.codeFreqBasis / L5data.settings.codeLength));
samplesPerChipL5 = L5data.settings.samplingFreq /(L5data.settings.codeFreqBasis);

%--- For all channels in the list ... 
for channelNr = channelList

    %--- Compute the travel times -----------------------------------------    
    travelTimeL1(channelNr) = (-trackResults(channelNr).remCodePhase(msOfTheSignal(channelNr))*samplesPerChip + ...
        trackResults(channelNr).absoluteSample(msOfTheSignal(channelNr))) / samplesPerCode;
    travelTimeL5(channelNr) = (-L5data.trackResults(channelNr).remCodePhase(msOfTheSignal(channelNr))*samplesPerChipL5 + ...
        L5data.trackResults(channelNr).absoluteSample(msOfTheSignal(channelNr))) / samplesPerCodeL5;
    
end

%--- Truncate the travelTime and compute pseudoranges ---------------------
minimumL1         = floor(min(travelTimeL1));
travelTimeL1      = travelTimeL1 - minimumL1 + settings.startOffset;
minimumL5         = floor(min(travelTimeL5));
travelTimeL5      = travelTimeL5 - minimumL5 + settings.startOffset;


%--- Convert travel time to a distance ------------------------------------
% The speed of light must be converted from meters per second to meters
% per millisecond. 
pseudorangesL5    = travelTimeL5 * (settings.c / 1000);
pseudorangesL1    = travelTimeL1 * (settings.c / 1000);

