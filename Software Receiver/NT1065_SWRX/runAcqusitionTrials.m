settings.skipNumberOfBytes = 53e6;
for i = 1:60
runAcquisitionWeakHeo;
resultsSNR(i)=acqResults.SNR;
resultsSNR_includingPeak(i)=acqResults.SNR_includingPeak;
settings.skipNumberOfBytes = settings.skipNumberOfBytes+53e6/10;
end
disp('excluding peak');
mean(resultsSNR)
std(resultsSNR)

disp('including peak');
mean(resultsSNR_includingPeak)
std(resultsSNR_includingPeak)