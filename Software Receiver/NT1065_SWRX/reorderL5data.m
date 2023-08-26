close all;
clear all;

% load in the L1 data as if its just finished the tracking
load('L1_NoError_TrackingResults.mat');
% load the L5 data and call it something elseto seperate it
L5data = load('L5_NoError_TrackingResults.mat');

% copy the L5 data
L5dataNew = L5data;

% generate a list of PRNs in the L5 data
for i = 1: length(channel)
    PRNlistL5(i) =  L5data.channel(i).PRN;
end

for i = 1: length(channel)
    % search for the current L1 PRN in the L5 channels 
    L5index = find(PRNlistL5 == channel(i).PRN);  
    if isempty(L5index)~=1
        % if its there, reorder to the correct L1 channel
        L5dataNew.trackResults(i)=L5data.trackResults(L5index);
    else
        % if its not there, stop the L1 channel being used in the solution
        trackResults(i).status='-';
    end
end
% change the navSolPeriod
settings.navSolPeriod=1000;
% save all workspace L1 and L5
save L1andL5reordered