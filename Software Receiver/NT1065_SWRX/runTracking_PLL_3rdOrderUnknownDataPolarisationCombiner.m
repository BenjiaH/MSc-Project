disp ('Starting processing...');


% choose the file
filePath = 'C:\sandbox\test signal generation\';
fileID = 'PRN_4_Dopp_270noiseAmp_20phase_0_bits_2';
settings.fileName = [filePath fileID '.dat']; 

[fid1, message] = fopen(settings.fileName, 'rb');

% choose the file
filePath = 'C:\sandbox\test signal generation\';
fileID = 'PRN_4_Dopp_270noiseAmp_20phase_90_bits_2';
settings.fileName = [filePath fileID '.dat']; 

[fid2, message] = fopen(settings.fileName, 'rb');


%If success, then process the data
if (fid > 0)
    
%% Initialize channels and prepare for the run ============================

    % Start further processing only if a GNSS signal was acquired (the
    % field FREQUENCY will be set to 0 for all not acquired signals)
    if (any(acqResults.carrFreq))
        channel = preRun(acqResults, settings);
        showChannelStatus(channel, settings);
    else
        % No satellites to track, exit
        disp('No GNSS signals detected, signal processing finished.');
        trackResults = [];
        return;
    end

%% Track the signal =======================================================
    startTime = now;
    disp (['   Tracking started at ', datestr(startTime)]);

    % Process all channels for given data block
    [trackResults, channel] = tracking_PLL3rdOrderUnknownDataPolarisationCombiner(fid1, fid2, channel, settings);

    % Close the data file
    fclose(fid);
    
    disp(['   Tracking is over (elapsed time ', ...
                                        datestr(now - startTime, 13), ')'])     

    % Auto save the acquisition & tracking results to a file to allow
    % running the positioning solution afterwards.
    disp('   Saving Acq & Tracking results to file "trackingResults.mat"')
    save('trackingResults', ...
                      'trackResults', 'settings', 'acqResults', 'channel');    
    disp ('   Ploting results...');
    if settings.plotTracking
        plotTracking(1:settings.numberOfChannels, trackResults, settings);
    end
end
