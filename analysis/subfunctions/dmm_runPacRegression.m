function dmm_runPacRegression(bids_dir,subj,epoch,freq,roi)
  
% define a few more variables
subj_str = sprintf('sub-%02.0f',subj);
save_dir = [bids_dir,'derivatives/',subj_str,'/'];   
if nargin<5 || isempty(roi); roi = 'source'; end 

% load data if required
if nargin<4 || isempty(freq)
    fprintf('loading data for sub-%02.0f, run %02.0f...\n',subj,epoch)
    filename = ['source/',subj_str,'_stage-07_run-',sprintf('%02.0f',epoch),'_',roi,'-pac.mat'];
    load([save_dir,filename],'freq')
end

% extract trialinfo
trlinfo = zeros(size(freq.trialinfo));
for trl = 1 : numel(freq.trialinfo)
    trlinfo(trl) = freq.trialinfo{trl}.mem_score;
end

% store nuisance regressors
nuisance = cat(ndims(freq.phapow)+2,repmat(freq.phapow,[1 1 1 size(freq.powpow,3)]),repmat(permute(freq.powpow,[1 2 4 3]),[1 1 size(freq.phapow,3),1]));
nuisance = permute(nuisance,[1 2 4 3 5]);

% reformat freq
freq = rmfield(freq,{'phase','bin_val','phapow','powpow'});
freq.powspctrm = permute(freq.powspctrm,[4 1 2 3]);
freq.dimord = 'rpt_chan_freq_time';

% load movement parameters
filename = ['meg/timeseries/',subj_str,'_stage-01_run-01_movement.mat'];
load([save_dir,filename],'dp');

% get relevant trials
dp = uni_matchMovement(freq.trialinfo,dp);
si = size(nuisance);
si([1 end]) = 1;
nuisance = cat(ndims(nuisance),repmat(dp,si),nuisance);

% do multiregression
freq = uni_getMultiReg(freq,nuisance,false);

% save data
fprintf('saving data for sub-%02.0f, run %02.0f...\n\n',subj,epoch)
filename = ['meg/timeseries/',subj_str,'_stage-07_run-',sprintf('%02.0f',epoch),'_',roi,'-split.mat'];
save([save_dir,filename],'freq');