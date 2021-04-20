function autorun_behaviour

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

% cycle through participants
for subj = 1 : nsubj
    
    % load data
    load(sprintf('H:/bids/meg_sequences19/sourcedata/tdr_logs/sub-%02.0f_task-MEM_beh.mat',subj),'log')
    
    % get number recall
    n_recall(subj,1) = sum(ismember(log.task_raw(:,9),'target') & ismember(log.task_raw(:,13),'target') & ~ismember(log.task_raw(:,17),'guess'));
    n_recall(subj,2) = sum((ismember(log.task_raw(:,9),'target') | ismember(log.task_raw(:,13),'target')) & ~ismember(log.task_raw(:,17),'guess')) - n_recall(subj,1);
    n_recall(subj,3) = sum((ismember(log.task_raw(:,9),'lure') & ismember(log.task_raw(:,13),'lure')) | ismember(log.task_raw(:,17),'guess'));
    
    % get scene/feature performance
    stim_recall(subj,1) = sum(ismember(log.task_raw(:,9),'target'));
    stim_recall(subj,2) = sum(ismember(log.task_raw(:,13),'target'));
end

% calculate percentage per participant
n_recall = (n_recall ./ 192) * 100;
stim_recall = (stim_recall ./ 192) * 100;

% run t-test for stim. types
[~,p,~,stat] = ttest(stim_recall(:,1),stim_recall(:,2));

% print results
fprintf('\nRecall percentages:\nComplete: %3.1f%%\nPartial: %3.1f%%\nForgotten: %3.1f%%\n',mean(n_recall,1))
fprintf('\nStimulus percentages:\nFeatures: %3.1f%%\nScenes: %3.1f%%\n',mean(stim_recall,1))
fprintf('\nStimulus t-test:\np-value: %3.3f\nt-value: %3.1f\n',p,stat.tstat)

% plot stimulus type data
cm_box  = flipud(brewermap(6,'Blues'));
h = figure ('units','centimeters','position',[18 2 8.5 4]); hold on
subplot(1,6,1:3); hold on
dmm_boxplot(n_recall(:,1),-0.5,'Blues');
dmm_boxplot(n_recall(:,2),1,'Reds');
dmm_boxplot(n_recall(:,3),2.5,'Reds');
for pp = 1 : 17; plot(0.6,n_recall(pp,1),'ko','markerfacecolor',cm_box(2,:),'markeredgecolor','none','markersize',2); end
for pp = 1 : 17; plot(2.1,n_recall(pp,2),'ko','markerfacecolor',cm_box(2,:),'markeredgecolor','none','markersize',2); end
for pp = 1 : 17; plot(3.6,n_recall(pp,3),'ko','markerfacecolor',cm_box(2,:),'markeredgecolor','none','markersize',2); end
set(gca,'xtick',[0.3 1.8 3.3],'xticklabel',{'Two','One','None'},'tickdir','out','fontname','calibri light','ytick',0:20:100,'yticklabel',{'0','','40','','80'});
ylabel('Percentage Recalled (%)'); xlabel('Number of Items Recalled')
xlim([-0.7 4.5]); ylim([0 80])

% plot stimulus type data
subplot(1,6,5:6); hold on
dmm_boxplot(stim_recall(:,1),-0.5,'Blues');
dmm_boxplot(stim_recall(:,2),1.7,'Reds');
for pp = 1 : 17; plot([0.6 1.6],[stim_recall(pp,1),stim_recall(pp,2)],'k-','color',[0.6 0.6 0.6]); end
for pp = 1 : 17; plot(0.6,stim_recall(pp,1),'ko','markerfacecolor',cm_box(2,:),'markeredgecolor','none','markersize',2); end
for pp = 1 : 17; plot(1.6,stim_recall(pp,2),'ko','markerfacecolor',cm_box(2,:),'markeredgecolor','none','markersize',2); end
set(gca,'xtick',[0 2.2],'xticklabel',{'Features','Scenes'},'tickdir','out','fontname','calibri light','ytick',0:25:100,'yticklabel',{'0','','50','','100'});
ylabel('Percentage Recalled (%)')
xlim([-0.7 2.9]); ylim([0 100])

% save
export_fig('figures/fig1c_boxplot.tiff','-transparent','-r1000',h)
