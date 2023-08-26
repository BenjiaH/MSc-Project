% Script postProcessing.m processes the raw signal from the specified data
% file (in settings) operating on blocks of 37 seconds of data.
%
% It runs acquisition code identifying the satellites in the file,

disp ('Starting processing...');

if (settings.complexInput==0) 
    dataAdaptCoeff=1;
else
    dataAdaptCoeff=2;
end

[fid, message] = fopen(settings.fileName, 'rb');

    %If success, then process the data
    if (fid > 0)

        % Move the starting point of processing. Can be used to start the
        % signal processing at any point in the data record (e.g. good for long
        % records or for signal processing in blocks).
        fseek(fid, dataAdaptCoeff*settings.skipNumberOfBytes, 'bof'); 
        % Find number of samples per spreading code
        samplesPerCode = round(settings.samplingFreq / ...
                           (settings.codeFreqBasis / settings.codeLength));

        % Read data for acquisition. 21ms of signal are needed for the fine
        % frequency estimation
        data  = fread(fid, dataAdaptCoeff*51*samplesPerCode, settings.dataType)';
    
        if (dataAdaptCoeff==2)    
            data1=data(1:2:end);    
            data2=data(2:2:end);    
            data=data2 + 1i .* data1;    
        end

        %--- Do the acquisition -------------------------------------------
        disp ('   Acquiring satellites...');
        acqResults = acquisitionL5_10ms(data, settings);
        plotAcquisition(acqResults);
    end; %if

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