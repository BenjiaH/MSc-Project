function [settings, EKF_track]  = initSettingsNT1065_config2_L1()
%Functions initializes and saves settings. Settings can be edited inside of
%the function, updated from the command line or updated using a dedicated
%GUI - "setSettings".  
%
%All settings are described inside function code.
%
%settings = initSettingsNT1065_config1()
%
%   Inputs: none
%
%   Outputs:
%       settings     - Receiver settings (a structure). 
%       EKF_track    - EKF tracking settings (a structure). 


%% Processing settings ====================================================
% Number of milliseconds to be processed used 36000 + any transients (see
% below - in Nav parameters) to ensure nav subframes are provided


settings.msToProcess        = 10000;        %[ms]

% Number of channels to be used for signal processing
settings.numberOfChannels   = 1;

% Move the starting point of processing. Can be used to start the signal
% processing at any point in the data record (e.g. for long records). fseek
% function is used to move the file read point, therefore advance is byte
% based only. 
load('skipNumberOfBytes.mat','skipNumberOfBytes');
settings.skipNumberOfBytes     = skipNumberOfBytes;
% settings.skipNumberOfBytes     = 100e6;

%% Raw signal file name and other parameter ===============================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode

load('deviceType.mat','deviceType');
switch deviceType
    case 'PC'
        settings.fileName   = 'E:\Users\benji\OneDrive\Project\MSc-Project\Software Receiver\CH1SIM12p5MHzconfig2_int8.dat';
    case 'WVD'
        settings.fileName   = 'C:\Users\eexyh39\OneDrive\Project\MSc-Project\Software Receiver\CH1SIM12p5MHzconfig2_int8.dat';
    otherwise
        settings.fileName   = 'C:\dataSandbox\reduced_samples_rateNT1065\reducedSimRate\CH1SIM12p5MHzconfig2_int8.dat';
end

%%'C:\dataSandbox\reduced_samples_rateNT1065\CH1config2_simSampling_L1_25MHz_L5_25MHz_5dBGlobal_int8.dat';

% settings.fileName           =  ...
% 'C:\Users\paulb\OneDrive - The University of Nottingham\HydroGNSS\dataCaptures\skydelDigitalNoiseTest\CH1config2_powerDrop_10_5_0_10dBATT_int8.dat';
% 'C:\Users\paulb\OneDrive - The University of Nottingham\HydroGNSS\dataCaptures\CH1L1L5config2test1_int8.dat';
%   'Zynq_Raw_Data_V2_Config2.log_int8_chan1.int8';

% Data type used to store one sample
settings.dataType           = 'int8';

% Intermediate, sampling and code frequencies
settings.IF                 = 14.58e6;      %[Hz]
settings.samplingFreq       = 99.375e6;     %[Hz]
settings.codeFreqBasis      = 1.023e6;      %[Hz]
settings.Doppler = 0;
% Account for any spectrum inversion by the RF front end
settings.spectrumInversion = -1;
% Define number of chips in a code period
settings.codeLength         = 1023;

%% Acquisition settings ===================================================
% Skips acquisition in the script postProcessing.m if set to 1
settings.skipAcquisition    = 0;
% plots FFT surfaces for each satellite if set to 1
settings.plotFFTs    = 0;
% List of satellites to look for. Some satellites can be excluded to speed
% up acquisition
settings.acqSatelliteList   = 2;         %[PRN numbers]
% settings.acqSatelliteList   = 1:32;         %[PRN numbers]
% Band around IF to search for satellite signal. Depends on max Doppler
settings.acqSearchBand      = 10;           %[kHz]
% Threshold for the signal presence decision rule
settings.acqThreshold       = 2.5;

%% Navigation solution settings ===========================================

% Period for calculating pseudoranges and position
settings.navSolPeriod       = 1000;          %[ms]

settings.measurementPoints = 1:ceil(settings.samplingFreq*(settings.navSolPeriod/1000)):(settings.samplingFreq*((settings.msToProcess+10000)/1000));
% Elevation mask to exclude signals from satellites at low elevation
settings.elevationMask      = 0;           %[degrees 0 - 90]
% Enable/dissable use of tropospheric correction
settings.useTropCorr        = 0;            % 0 - Off
                                            % 1 - On

% True position of the antenna in UTM system (if known). Otherwise enter
% all NaN's and mean position will be used as a reference .
settings.truePosition.E     = nan;
settings.truePosition.N     = nan;
settings.truePosition.U     = nan;

%% Plot settings ==========================================================
% Enable/disable plotting of the tracking results for each channel
settings.plotTracking       = 1;            % 0 - Off
                                            % 1 - On

%% Constants ==============================================================

settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 68.802;       %[ms] Initial sign. travel time

%% Initialisation for EKF tracking architecture

% Number of states in the EKF
EKF_track.STATES=3;
% Iteration time of the EKF
EKF_track.Ts=0.02; 
% Measurement noise covariance
% Known data
EKF_track.R=0.5;
% Unknown data
% EKF_track.R=12.5;
% Process noise terms
EKF_track.Q_phi=0.363;         
EKF_track.Q_omega=5.85;
% Stationary setting
EKF_track.Q_omegaDot=0.008;
% low dynamics setting
% EKF_track.Q_omegaDot=0.25;
% State transition matrix 
EKF_track.Phi=zeros(EKF_track.STATES,EKF_track.STATES);      
EKF_track.Phi(1,1)=1;
EKF_track.Phi(1,2)=EKF_track.Ts;
EKF_track.Phi(1,3)=EKF_track.Ts*EKF_track.Ts*0.5;
EKF_track.Phi(2,2)=1;
EKF_track.Phi(2,3)=EKF_track.Ts;
EKF_track.Phi(3,3)=1;
% Identity matrix
EKF_track.I=eye(EKF_track.STATES);
% System noise covariance matrix
EKF_track.Q=zeros(EKF_track.STATES,EKF_track.STATES);           
EKF_track.Q(1,:)=[EKF_track.Q_phi*EKF_track.Ts+EKF_track.Q_omega*EKF_track.Ts^3/3+EKF_track.Q_omegaDot*EKF_track.Ts^5/20 EKF_track.Q_omega*EKF_track.Ts^2/2+EKF_track.Q_omegaDot*EKF_track.Ts^4/8   EKF_track.Q_omegaDot*EKF_track.Ts^3/3    ];
EKF_track.Q(2,:)=[EKF_track.Q_omega*EKF_track.Ts^2/2+EKF_track.Q_omegaDot*EKF_track.Ts^4/8                               EKF_track.Q_omega*EKF_track.Ts+EKF_track.Q_omegaDot*EKF_track.Ts^3/3       EKF_track.Q_omegaDot*EKF_track.Ts^2/2    ];
EKF_track.Q(3,:)=[EKF_track.Q_omegaDot*EKF_track.Ts^3/6                                                                  EKF_track.Q_omegaDot*EKF_track.Ts^2/2                                      EKF_track.Q_omegaDot*EKF_track.Ts        ];
% State estimates
EKF_track.X_minus=zeros(EKF_track.STATES,1);
EKF_track.X_plus=zeros(EKF_track.STATES,1);
% Error covariance matrix 
EKF_track.P_plus=zeros(EKF_track.STATES,EKF_track.STATES); 
EKF_track.P_minus=zeros(EKF_track.STATES,EKF_track.STATES);
EKF_track.H=[1,0,0];
EKF_track.K=zeros(3,1);
