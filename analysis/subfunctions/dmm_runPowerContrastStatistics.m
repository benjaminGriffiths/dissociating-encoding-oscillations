function dmm_runPowerContrastStatistics(bids_dir,epoch1,epoch2)
   
% load data
run_str = sprintf('run-%02.0f',epoch1);
load([bids_dir,'derivatives/group/meg/tfr/group_reg_',run_str,'.mat'],'grand_freq')
data1 = grand_freq; clear grand_freq
run_str = sprintf('run-%02.0f',epoch2);
load([bids_dir,'derivatives/group/meg/tfr/group_reg_',run_str,'.mat'],'grand_freq')
data2 = grand_freq; clear grand_freq

% load layout
load([bids_dir,'/sourcedata/layouts/lay_cmb.mat'],'lay')

% get neighbours
cfg = [];
cfg.method = 'triangulation';
cfg.layout = lay;
nb_cmb = ft_prepare_neighbours(cfg);

% set random seed
rng(1)

% define stat design
design      = zeros(2,size(data1.powspctrm,1)*2);
design(1,:) = repmat(1:size(data1.powspctrm,1),[1 2]);
design(2,:) = [ones(1,size(data1.powspctrm,1)),ones(1,size(data1.powspctrm,1))+1];

% define stat config structure
cfg                     = [];
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.neighbours          = nb_cmb;
cfg.minnbchan           = 3;
cfg.numrandomization    = 2000;
cfg.ivar                = 2;
cfg.uvar                = 1;
cfg.parameter           = 'powspctrm';
cfg.design              = design;
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correcttail         = 'prob';
cfg.tail                = -1;
cfg.latency             = [0 1.5];
cfg.frequency           = [8 30];
stat                    = ft_freqstatistics(cfg,data1,data2);

% get cluster details
[stat,cluster_extent]   = dmm_getClusterDetails(stat);

% save stat
save([bids_dir,'derivatives/group/meg/tfr/group_stat_contrast-run-01vs02.mat'],'stat','cluster_extent','-v7.3')
