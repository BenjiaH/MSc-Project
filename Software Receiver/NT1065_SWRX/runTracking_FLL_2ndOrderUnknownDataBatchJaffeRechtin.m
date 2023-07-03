disp ('Starting processing...');
filenames = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v'];
for i = 1:length(filenames)
    settings.fileName           = ... 
        ['\\esplabnas1\FP7-Galileo\2015 Beidou BB Interference\Matlab\SimulatedDataForTest_EKF\14s\20151221\NewFile01' filenames(i) '.dat'];
         
    disp (['   Running file ' filenames(i)]);
    [fid, message] = fopen(settings.fileName, 'rb');

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
        [trackResults, channel] = tracking_FLL_2ndOrderUnknownDataJaffeRechtin(fid, channel, settings);

        % Close the data file
        fclose(fid);

        disp(['   Tracking is over (elapsed time ', ...
                                            datestr(now - startTime, 13), ')'])     

        % Auto save the acquisition & tracking results to a file to allow
        % running the positioning solution afterwards.
        disp('   Saving Acq & Tracking results to file "trackingResults.mat"')
        save(['trackingResults' filenames(i)], ...
                          'trackResults', 'settings', 'acqResults', 'channel');    
        disp ('   Ploting results...');
        if settings.plotTracking
            plotTracking(1:settings.numberOfChannels, trackResults, settings);
        end
    end
end
