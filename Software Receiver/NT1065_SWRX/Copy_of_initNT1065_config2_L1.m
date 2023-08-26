%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis and Dennis M. Akos
% Written by Darius Plausinaitis and Dennis M. Akos
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
%
%Script initializes settings and environment of the software receiver.
%Then the processing is started.

%--------------------------------------------------------------------------
% CVS record:
% $Id: init.m,v 1.14.2.21 2006/08/22 13:46:00 dpl Exp $

%% Clean up the environment first =========================================
clear; close all; clc;

% =========================================
skipNumberOfBytes = 46250;
% skipNumberOfBytes = 100e6 + 17e3;
% deviceType = 'WVD';
% deviceType = 'PC';
% deviceType = 'N/A';
DEBUG_ENABLE = false;
% DEBUG_ENABLE = true;
% =========================================

% save('deviceType.mat',"deviceType");
save('skipNumberOfBytes.mat',"skipNumberOfBytes");

format ('compact');
format ('long', 'g');

%--- Include folders with functions ---------------------------------------
addpath include             % The software receiver functions
addpath geoFunctions        % Position calculation related functions

%% Print startup ==========================================================
fprintf(['\n',...
    'Welcome \n\n']);
fprintf('                   -------------------------------\n\n');

%% Initialize constants, settings =========================================
[settings, EKF_track] = initSettingsNT1065_config2_L1();

if ~DEBUG_ENABLE
    clearvars skipNumberOfBytes deviceType
end

%% Generate plot of raw data and ask if ready to start processing =========
try
    fprintf('Probing data (%s)...\n', settings.fileName)
%     probeData(settings);
    %% Check the number of arguments ==========================================
%     varargin = settings;
% if (nargin == 1)
%     settings = deal(varargin{1});
    fileNameStr = settings.fileName;
% elseif (nargin == 2)
%     [fileNameStr, settings] = deal(varargin{1:2});
%     if ~ischar(fileNameStr)
%         error('File name must be a string');
%     end
% else
%     error('Incorect number of arguments');
% end
    
% Generate plot of raw data ==============================================
[fid, message] = fopen(fileNameStr, 'rb');

if (fid > 0)
%     Move the starting point of processing. Can be used to start the
%     signal processing at any point in the data record (e.g. for long
%     records).
    fseek(fid, settings.skipNumberOfBytes, 'bof');    
    
    % Find number of samples per spreading code
    samplesPerCode = round(settings.samplingFreq / ...
                           (settings.codeFreqBasis / settings.codeLength))
                      
    % Read 10ms of signal
    [data, count] = fread(fid, [1, 10*samplesPerCode], settings.dataType);
%     data = ad9361_I_4bits;
%     count = samplesPerCode;
    fclose(fid);
%     for i = 1:length(data)
%        if (data(i) < -30)&&(data(i) > -90)
%            data(i) = 1;
%        elseif (data(i) >= -30)&&(data(i) < 30)
%            data(i) = -3;
%        elseif (data(i) >= 30)
%            data(i) = -1;
%        elseif (data(i) <= -90)
%            data(i) = 3;
%        end
%     end
    
    
    if (count < 10*samplesPerCode)
        % The file is to short
        error('Could not read enough data from the data file.');
    end
    
    %--- Initialization ---------------------------------------------------
    figure(100);
    clf(100);
    
    timeScale = 0 : 1/settings.samplingFreq : 5e-3;    
    
    %--- Time domain plot -------------------------------------------------
    subplot(2, 2, 1);
    plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
         data(1:round(samplesPerCode/50)));
     
    axis tight;
    grid on;
    title ('Time domain plot');
    xlabel('Time (ms)'); ylabel('Amplitude');
    
    %--- Frequency domain plot --------------------------------------------
    subplot(2,2,2);
    pwelch(data-mean(data), 16384/8, 1024, 2048, settings.samplingFreq/1e6)
    
    axis tight;
    grid on;
    title ('Frequency domain plot');
    xlabel('Frequency (MHz)'); ylabel('Magnitude');
    
    %--- Histogram --------------------------------------------------------
    subplot(2, 2, 3.5);
%     hist(data, -128:128)
    h = histogram(data);
%     H = hist(data, -8:8)
    
%     davg=std(abs(data))
    dmax = max(abs(data)) + 1;
    axis tight;
    adata = axis;
    axis([-dmax dmax adata(3) adata(4)]);
    grid on;
    title ('Histogram'); 
    xlabel('Bin'); ylabel('Number in bin');
    
    T = tabulate(data);
    x = T(:,1)';
    y = T(:,2)';
    b = bar(x, y);
%     ylim(0 : 3.6e6);
    set(gca, 'Ygrid','on'); %纵坐标刻度显示网格
    xtips1 = b.XEndPoints;
    ytips1 = b.YEndPoints; %获取 Bar 对象的 XEndPoints 和 YEndPoints 属性
    labels1 = string(b.YData); %获取条形末端的坐标
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
%     y = [round(T(1, 3)), round([T(2, 3)]), round(T(3, 3)), round(T(4, 3))];
%     
%     xtips1 = h.BinEdges;
%     ytips1 = h.BinEdges; %获取 Bar 对象的 XEndPoints 和 YEndPoints 属性
%     labels1 = string(h.YData); %获取条形末端的坐标
%     text(xtips1,ytips1,'HorizontalAlignment','center',...
%         'VerticalAlignment','bottom')
% 
% %     hBin=h.BinEdges(1:end-1)+h.BinWidth/2;
% %     text(hBin,["1","2","3","4"]);

else
    %=== Error while opening the data file ================================
    error('Unable to read file %s: %s.', fileNameStr, message);
end % if (fid > 0)
catch
    % There was an error, print it and exit
    errStruct = lasterror;
    disp(errStruct.message);
    disp('  (change settings in "initSettingsNSL_26MHz.m" to reconfigure)')    
    return;
end
    
disp('  Raw IF data plotted ')
disp('  (change settings in "initSettingsNSL_26MHz.m" to reconfigure)')
disp(' ');
disp('  Processing is now split into three stages;  Acquisition, Tracking and Navigation')
disp('  Use runAcquisition and runTracking_...(many different types) and runNav to perform each stage ')

