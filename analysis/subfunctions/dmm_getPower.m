function freq = dmm_getPower(bids_dir,subj,epoch)
   
% define a few directories
fprintf('working on sub-%02.0f, epoch %01.0f...\n',subj,epoch); tic
subj_str = sprintf('sub-%02.0f',subj);
subj_dir = [bids_dir,'derivatives/',subj_str,'/'];   
  
% load in data 
meg_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',epoch),'_meg.mat'];
load(meg_file,'data');

% get low-frequency tfr
cfg             = [];
cfg.keeptrials  = 'yes';
cfg.output      = 'pow';
cfg.method      = 'wavelet';
cfg.pad         = 'nextpow2';
cfg.foi         = 2:40;
cfg.width       = 6;
if epoch == 1; cfg.toi = -0.5 : 0.05 : 2; 
else; cfg.toi = -0.5 : 0.05 : 3; end
freq{1,1}       = ft_freqanalysis(cfg,data);

% get high-frequency tfr
cfg             = [];
cfg.keeptrials  = 'yes';
cfg.output      = 'pow';
cfg.method      = 'mtmconvol';
cfg.pad         = 'nextpow2';
cfg.foi         = 40:4:100;
cfg.t_ftimwin   = zeros(size(cfg.foi))+0.2;
cfg.tapsmofrq   = cfg.foi/4;
if epoch == 1; cfg.toi = -0.5 : 0.05 : 2; 
else; cfg.toi = -0.5 : 0.05 : 3; end
freq{1,2}       = ft_freqanalysis(cfg,data);
clear data

% save data
fprintf('saving raw tfr data...\n')
save_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',epoch),'_pow-raw.mat'];    
save(save_file,'freq','-v7.3');