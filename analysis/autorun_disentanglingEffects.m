function autorun_disentanglingEffects

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

%% Load Data
% load template hippocampus and peaks
load([bids_dir,'derivatives/group/outliers/mri_grid.mat'],'idx')

% load pac data
load([bids_dir,'derivatives/group/meg/pac/grand_reg_run-01.mat'])
tmp = source.pow(:,source.inside);
percept_pac = mean(tmp(:,idx.hippocampus),2);
load([bids_dir,'derivatives/group/meg/pac/grand_reg_run-02.mat'])
tmp = source.pow(:,source.inside);
assc_pac = mean(tmp(:,idx.hippocampus),2);

% load power data
load([bids_dir,'derivatives/group/meg/tfr/group_reg_run-01.mat'],'grand_freq')
load([bids_dir,'derivatives/group/meg/tfr/group_stat_run-01.mat'],'stat')
grand_freq = ft_selectdata(struct('latency',[stat.time(1) stat.time(end)],'frequency',[stat.freq(1) stat.freq(end)]),grand_freq);
percept_pow = mean(grand_freq.powspctrm(:,stat.negclusterslabelmat==1),2)*-1;
load([bids_dir,'derivatives/group/meg/tfr/group_reg_run-02.mat'],'grand_freq')
grand_freq = ft_selectdata(struct('latency',[stat.time(1) stat.time(end)],'frequency',[stat.freq(1) stat.freq(end)]),grand_freq);
assc_pow = mean(grand_freq.powspctrm(:,stat.negclusterslabelmat==1),2)*-1;

% convert to same unit space
percept_pow = percept_pow ./ std(percept_pow);
percept_pac = percept_pac ./ std(percept_pac);
assc_pow = assc_pow ./ std(assc_pow);
assc_pac = assc_pac ./ std(assc_pac);

% create exportable file
tbl = table(percept_pow,assc_pow,percept_pac,assc_pac);
writetable(tbl,'tmp.csv')

%% Plot Interaction
figure; hold on;
dmm_boxplot(tbl.percept_pow,1,'Reds')
dmm_boxplot(tbl.percept_pac,2,'Reds')
dmm_boxplot(tbl.assc_pow,4,'Reds')
dmm_boxplot(tbl.assc_pac,5,'Reds')
plot([1.5 4.5],[mean(tbl.percept_pow) mean(assc_pow)])
plot([2.5 5.5],[mean(tbl.percept_pac) mean(assc_pac)])
set(gca,'xtick',[2 5],'xticklabel',{'perception','association'},'tickdir','out'); xlim([0.8 6.2])
ylim([-3 3]); yline(0,'k-'); ylabel('Memory-related change in MEG measure (s.d.)');
legend('alpha/beta power [inverted]','theta-gamma coupling','location','southeastoutside')

%% Correlate Effects (supp. fig. 4)
% cycle through participants
for subj = 1 : 17
    
    % get correlations
    z(:,:,subj) = dmm_runCorrelation(bids_dir,subj);
end

% t-test
for i = 1 : 2
    for j = 1 : 2
        [~,p(i,j),~,tmp] = ttest(squeeze(z(i,j,:)),zeros(17,1),'tail','left');
        tval(i,j) = tmp.tstat;
    end
end

% plot result
figure;
imagesc(squeeze(mean(z,3))); axis square
colorbar(); colormap(flipud(brewermap(128,'Purples')));
caxis([-0.6 0]);
set(gca,'xtick',1:2,'ytick',1:2)


