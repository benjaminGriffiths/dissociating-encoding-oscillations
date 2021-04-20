function autorun_multiregPower

%% Prepare Workspace
% set defaults
nsubj = 17;

% define a few essential directories
code_dir = 'C:/Users/ra34fod/github/dissociating-encoding-oscillations/analysis/';
bids_dir = 'H:/bids/meg_sequences19/';

% set working directory
cd(code_dir)

%% Run Sensor Level Analysis
% cycle through all participants of interest
for subj = 1 : nsubj

    % cycle through epochs
    for epoch = 1 : 3
    
        % get TFR
        freq = dmm_getPower(bids_dir,subj,epoch);

        % correct power
        freq = dmm_correctPower(bids_dir,subj,epoch,freq);

        % fit model    
        dmm_runPowerRegression(bids_dir,subj,epoch,freq);  
        clear freq epoch
    end
end
  
%% Run Sensor-Level Statistics
% cycle through epochs
for epoch = 1 : 3
    
    % run statistics
    dmm_runStatistics(bids_dir,nsubj,epoch,2)
end

% contrast perception and association
dmm_runPowerContrastStatistics(bids_dir,1,2)


