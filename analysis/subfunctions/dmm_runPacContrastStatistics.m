function dmm_runPacContrastStatistics(bids_dir,nsubj,epoch1,epoch2)
    
% load source details
load([bids_dir,'derivatives/group/outliers/mri_grid.mat'],'mri','idx')

% load data
fprintf('loading group data...\n')
load([bids_dir,'derivatives/group/meg/pac/grand_reg_run-',sprintf('%02.0f',epoch1),'.mat'],'source')
data1 = source; clear source
load([bids_dir,'derivatives/group/meg/pac/grand_reg_run-',sprintf('%02.0f',epoch2),'.mat'],'source')
data2 = source; clear source

% create dummy freq structure
chan_idx = find(data1.inside);
hipp_idx = chan_idx(idx.hippocampus);
freq1 = struct('label',{{'pac'}},'time',1,'freq',1,'powspctrm',mean(data1.pow(:,hipp_idx),2),'dimord','subj_chan_freq_time','cfg',[]);
freq2 = struct('label',{{'pac'}},'time',1,'freq',1,'powspctrm',mean(data2.pow(:,hipp_idx),2),'dimord','subj_chan_freq_time','cfg',[]);

% set random seed
rng(1)

% define stat design
design      = zeros(2,size(freq1.powspctrm,1)*2);
design(1,:) = repmat(1:size(freq1.powspctrm,1),[1 2]);
design(2,:) = [ones(1,size(freq1.powspctrm,1)),ones(1,size(freq1.powspctrm,1))+1];

% define stat config structure
cfg                     = [];
cfg.method              = 'montecarlo';
cfg.correctm            = 'no';
cfg.numrandomization    = 5000;
cfg.ivar                = 2;
cfg.uvar                = 1;
cfg.parameter           = 'powspctrm';
cfg.design              = design;
cfg.statistic           = 'ft_statfun_depsamplesT';  
cfg.tail                = 1;
stat                    = ft_freqstatistics(cfg,freq1,freq2);
stat.dz                 = abs(stat.stat ./ sqrt(nsubj));

% extract metrics
percept_pac = freq2.powspctrm;
binding_pac = freq1.powspctrm;

% plot
cm_box  = flipud(brewermap(6,'Reds'));
h = figure ('units','centimeters','position',[18 2 6 6]); hold on
dmm_boxplot(percept_pac,-0.5,'Blues');
dmm_boxplot(binding_pac,1.7,'Reds');
for pp = 1 : 17; plot([0.6 1.6],[percept_pac(pp),binding_pac(pp)],'k-','color',[0.6 0.6 0.6]); end
for pp = 1 : 17; plot(0.6,percept_pac(pp),'ko','markerfacecolor',[0.6 0.6 0.6],'markeredgecolor','none','markersize',4); end
for pp = 1 : 17; plot(1.6,binding_pac(pp),'ko','markerfacecolor',cm_box(2,:),'markeredgecolor','none','markersize',4); end
set(gca,'xtick',[0 2],'xticklabel',{'Perception','Binding'},'tickdir','out','fontname','calibri light')
ylabel(sprintf('Memory-Related Change in Power\n(Standardised Beta Coefficent)'))
xlim([-0.7 2.9]); ylim([-1 1])

% add signficance
plot([0 2.2],[0.8 0.8],'k-'); plot([1.1 1.1],[0.875 0.875],'kx','markersize',4)

% save
export_fig('figures/fig3d_boxplot.tiff','-transparent','-r1000',h)
    
