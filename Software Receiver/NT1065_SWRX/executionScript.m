
% reorder results to have the PRNs on the same channels
reorderL5data;

% do this to include the necessary directories
initNT1065_config2_L1

% load the reordered data
load('L1andL5reordered.mat');

% choose the setting for navigation mode
% settings.navMode = 'L1only';
settings.navMode = 'L5only';
% settings.navMode = 'L1andL5';  % note needs iono free combination 
runNav