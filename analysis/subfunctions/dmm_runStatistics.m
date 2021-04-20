function dmm_runStatistics(bids_dir,nsubj,epoch,reg)
       
%% Get Group Averages 
% predefine group cell
group_freq = cell(nsubj,1);

% define string for epoch
run_str = sprintf('run-%02.0f',epoch);

% cycle through all participants of interest
fprintf('\nloading group grand_freq...\n')
for subj_num = 1 : nsubj
    
    % load regression grand_freq
    subj_str = sprintf('sub-%02.0f',subj_num);
    save_dir = [bids_dir,'derivatives/',subj_str,'/'];   
    save_file = [save_dir,'meg/timeseries/',subj_str,'_stage-08_',run_str,'_pow-reg.mat'];
    load(save_file,'freq');
  
    % add to group structure
    group_freq{subj_num,1} = freq{reg};
end
    
% get grand average
cfg = [];
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
grand_freq = ft_freqgrandaverage(cfg,group_freq{:});

% save group grand_freq
fprintf('saving...\n')
save([bids_dir,'derivatives/group/meg/tfr/group_reg_',run_str,'.mat'],'grand_freq','-v7.3')
fprintf('group power calculated...\n')

%% Prepare Layout
% load layout
load([bids_dir,'/sourcedata/layouts/lay_cmb.mat'],'lay')

% get neighbours
cfg = [];
cfg.method = 'triangulation';
cfg.layout = lay;
nb_cmb = ft_prepare_neighbours(cfg);

%% Run Alpha/Beta Statistics
% set random seed
rng(1)

% define null hyp
null_hyp = grand_freq;
null_hyp.powspctrm = zeros(size(null_hyp.powspctrm));

% define stat design
design      = zeros(2,size(grand_freq.powspctrm,1)*2);
design(1,:) = repmat(1:size(grand_freq.powspctrm,1),[1 2]);
design(2,:) = [ones(1,size(grand_freq.powspctrm,1)),ones(1,size(grand_freq.powspctrm,1))+1];

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
if epoch == 2; cfg.tail = 0; else; cfg.tail = -1; end
cfg.correcttail         = 'prob';
if epoch == 1; cfg.latency = [0 1.5]; else; cfg.latency = [0 3]; end
cfg.frequency           = [8 30];
stat                    = ft_freqstatistics(cfg,grand_freq,null_hyp);

% get cluster details
[stat,cluster_extent]   = dmm_getClusterDetails(stat);

% save stat
save([bids_dir,'derivatives/group/meg/tfr/group_stat_',run_str,'.mat'],'stat','cluster_extent','-v7.3')
