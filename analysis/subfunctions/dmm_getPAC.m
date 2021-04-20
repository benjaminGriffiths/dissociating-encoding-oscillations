function freq = dmm_getPAC(bids_dir,subj,epoch,peaks)
       
% define a few more variables
subj_str = sprintf('sub-%02.0f',subj);
save_dir = [bids_dir,'derivatives/',subj_str,'/'];   

% load in data
fprintf('working on sub-%02.0f, run %02.0f...\n',subj,epoch);
filename = ['source/',subj_str,'_stage-07_run-',sprintf('%02.0f',epoch),'_source.mat'];
load([save_dir,filename],'source');
data = source; clear source

% get memory
trlinfo = zeros(numel(data.trialinfo),1);
for j = 1 : numel(trlinfo)
    trlinfo(j) = data.trialinfo{j}.mem_score;
end

% define memory values           
mem_val = [2 1 0];

% get smallest number of trials in memory condition
min_n = min([sum(trlinfo == 0) sum(trlinfo == 1) sum(trlinfo == 2)]);
trls = [];

% select subset of trials in memory conditions with more than min.
for j = 1 : 3
    t = find(trlinfo==mem_val(j));
    tidx = round(linspace(1,numel(t),min_n));
    trls(end+1:end+min_n,1) = t(tidx);
end

% calculate MI
cfg                 = [];
cfg.trials          = trls;
if epoch == 1; cfg.latency = [0.5 1.5]; else; cfg.latency = [0.5 3]; end
cfg.phasefreq       = [-0.5 0.5] + peaks(1);
cfg.powerfreq       = [-5 5] + peaks(2);
cfg.nbins           = 12;
cfg.keeptrials      = 'yes';
cfg.zscore          = 'yes';
freq                = uni_getBasicPAC(cfg,data);
clear data

% save data
filename = ['source/',subj_str,'_stage-07_run-',sprintf('%02.0f',epoch),'_source-pac.mat'];
save([save_dir,filename],'freq');
