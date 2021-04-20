function freq = dmm_runPowerRegression(bids_dir,subj,epoch,freq)
    
% define a few directories
fprintf('preparing regression...\n');
subj_str = sprintf('sub-%02.0f',subj);
subj_dir = [bids_dir,'derivatives/',subj_str,'/'];   
 
% define meg file
meg_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',epoch),'_pow-corr.mat'];
      
% load data if required
if nargin < 4
    fprintf('loading data file...\n');
    load(meg_file,'freq');    
else
    fprintf('using inputted data structure...\n');
end

% load movement parameters
motion_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-01_run-01_movement.mat'];
load(motion_file,'dp');

% get relevant trials
dp = uni_matchMovement(freq.trialinfo,dp);

% do multiregression
freq = uni_getMultiReg(freq,dp,true);

% save data
fprintf('saving fitted data...\n')
save_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',epoch),'_pow-reg.mat'];
save(save_file,'freq');