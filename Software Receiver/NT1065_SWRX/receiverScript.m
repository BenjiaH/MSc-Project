% initialise
initNT1065_config1_L1

% choose the file
filePath = 'C:\sandbox\test signal generation\';
fileID = 'testOutput_8bits_blksize_65536';
settings.fileName = [filePath fileID '.dat'];  

% probe the file
probeData(settings);

% acquire
runAcquisition

% track
runTracking_PLL_3rdOrderUnknownData

% calculate CNo after 5 seconds
CNo = mean(trackResults.CNo(5000:end));

% save results
save(['trackResults' fileID], 'trackResults','CNo');
