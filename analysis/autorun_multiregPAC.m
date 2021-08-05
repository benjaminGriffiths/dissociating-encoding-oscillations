function autorun_multiregPAC

% clear workspace
close all
clearvars
clc

% set defaults
nsubj = 17;

% define a few essential directories
code_dir = 'C:/Users/ra34fod/github/dissociating-encoding-oscillations/analysis/';
bids_dir = 'H:/bids/meg_sequences19/';

% set working directory
cd(code_dir)
addpath([code_dir,'subfunctions'])

% load template hippocampus and peaks
load([bids_dir,'derivatives/group/outliers/mri_grid.mat'],'idx')

%% Calculate Whole-Brain PAC
% load in peak freqs
load([bids_dir,'derivatives/group/meg/pac/peak_freq.mat'],'peak_freq')

% cycle through all participants of interest
for subj = 1: nsubj

    % cycle through epochs
    for epoch = 1:3
        
        % calculate PAC
        freq = dmm_getPAC(bids_dir,subj,epoch,peak_freq(subj,:));

        % run regression
        dmm_runPacRegression(bids_dir,subj,epoch,freq) 
    end
end

% cycle through epochs
for epoch = 1 : 2
    
    % run statistics
    dmm_runHippVsRestStatistics(bids_dir,nsubj,epoch) % test constant
end

% run contrast statistics
dmm_runPacContrastStatistics(bids_dir,nsubj,2,1)

