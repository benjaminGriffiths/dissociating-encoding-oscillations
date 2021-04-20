function z = dmm_runCorrelation(bids_dir,subj)
  
% define a few more variables
subj_str = sprintf('sub-%02.0f',subj);
save_dir = [bids_dir,'derivatives/',subj_str,'/'];   
  
%% Load Data
% update user
fprintf('loading data for sub-%02.0f...\n',subj)

% load template hippocampus and peaks
load([bids_dir,'derivatives/group/outliers/mri_grid.mat'],'idx')

% cycle through each data pair
z = zeros(2,2);
for i = 1 : 2
    
    % load PAC data
    filename = ['source/',subj_str,'_stage-07_run-',sprintf('%02.0f',i),'_source-pac.mat'];
    load([save_dir,filename],'freq')
    pac = freq; clear freq
    
    % cycle through each data pair
    for j = 1 : 2
        
        % load power data
        filename = ['meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',j),'_pow-corr.mat'];
        load([save_dir,filename],'freq')
        power = freq; clear freq
        
        % get correlations for each pair
        z(i,j) = internal_correlation(power,pac,idx);
    end
end

end

function z = internal_correlation(power,pac,idx)

%% Extract Trialinfo
% get trialinfo
pac_info = pac.trialinfo;
pow_info = power.trialinfo;

%% Restrict Data to ROIs
% update user
fprintf('restricting ROIs...\n')

% restrict PAC to hipp.
tgc = mean(squeeze(permute(pac.powspctrm(idx.hippocampus,:,:,:),[4 1 2 3])),2);
clear pac

% load a/b cluster
load('H:/bids/meg_sequences19/derivatives/group/meg/tfr/group_stat_run-01.mat','stat')
pow = mean(power.powspctrm(:,stat.negclusterslabelmat==1),2); 
clear power

%% Match Trials
% update user
fprintf('matching trials...\n')

% extract association trialinfo
pac_no  = zeros(size(pac_info));
pac_mem = zeros(size(pac_info));
for trl = 1 : numel(pac_info)
    pac_no(trl) = pac_info{trl}.trl_num_enc;
    pac_mem(trl) = pac_info{trl}.mem_score;
end

% drop pac repetitions
pac_no(find(diff(pac_no)<0,1,'first')+1:end) = pac_no(find(diff(pac_no)<0,1,'first')+1:end)+192;

% extract perception trialinfo
pow_no  = zeros(size(pow_info));
for trl = 1 : numel(pow_info)
    pow_no(trl) = pow_info{trl}.trl_num_enc;
end

% find matching trials
pac_match  = ismember(pac_no,pow_no);
pow_match  = ismember(pow_no,pac_no);
pac_mem    = pac_mem(pac_match);

%% Run Regression Model
% update user
fprintf('running correlation...\n')

% create matrices
y = tgc(pac_match);
X = [pow(pow_match) pac_mem];

% fit linear model
[~,~,stat] = glmfit(X,y);
obs_t = stat.t(2);

% get permuted r-values
perm_t = zeros(100,1);
for p = 1 : 100
    
    % correlate all
    [~,~,stat] = glmfit(X,y(randperm(numel(y)))); 
    perm_t(p,1) = stat.t(2);
end

% standarise results
z = (obs_t - mean(perm_t)) ./ std(perm_t);

% chuck out results
fprintf('done...\n\n')

end

