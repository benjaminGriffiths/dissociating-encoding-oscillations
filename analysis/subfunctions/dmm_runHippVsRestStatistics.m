function dmm_runHippVsRestStatistics(bids_dir,nsubj,epoch)
    
% cycle through participants
group_pac = cell(nsubj,3);
for subj = 1 : nsubj
    
    % define a few more variables
    subj_str = sprintf('sub-%02.0f',subj);
    save_dir = [bids_dir,'derivatives/',subj_str,'/'];   

    % load data
    filename = ['meg/timeseries/',subj_str,'_stage-07_run-',sprintf('%02.0f',epoch),'_source-split.mat'];
    load([save_dir,filename],'freq');
    
    % extract PAC data
    for i = 1 : numel(freq)
        group_pac{subj,i} = freq{i};
    end
end

% get grand data structure
for i = 1 : size(group_pac,2)
    grand_freq{i} = uni_combineData(group_pac(:,i),{'powspctrm'});
end

% load source details
load([bids_dir,'derivatives/group/outliers/mri_grid.mat'],'mri','idx')

% convert to source structure
source.pos          = mri.wholeBrain.pos;
source.inside       = mri.wholeBrain.inside;
source.dim          = mri.wholeBrain.dim;
source.time         = grand_freq{2}.time;
source.freq         = grand_freq{2}.freq;
source.powdimord    = 'rpt_pos';
source.cfg          = [];

% fit power data
pow = zeros(size(grand_freq{2}.powspctrm,1),numel(source.inside));
pow(:,source.inside) = grand_freq{2}.powspctrm;
source.pow = pow;

% save data
fprintf('saving group data...\n')
save([bids_dir,'derivatives/group/meg/pac/grand_reg_run-',sprintf('%02.0f',epoch),'.mat'],'source')

%% Run Hippocampus Analysis
% get pac at hippocampus
source_pac = mean(grand_freq{2}.powspctrm(:,idx.hippocampus),2);

% create dummy freq structure
freq = struct('label',{{'pac'}},'time',1,'freq',1,'powspctrm',source_pac,'dimord','subj_chan_freq_time','cfg',[]);

% set random seed
rng(1)

% define null hyp
null_hyp     = freq;
null_hyp.powspctrm = zeros(size(null_hyp.powspctrm));

% define stat design
design      = zeros(2,size(freq.powspctrm,1)*2);
design(1,:) = repmat(1:size(freq.powspctrm,1),[1 2]);
design(2,:) = [ones(1,size(freq.powspctrm,1)),ones(1,size(freq.powspctrm,1))+1];

% define stat config structure
cfg                     = [];
cfg.method              = 'montecarlo';
cfg.correctm            = 'no';
cfg.numrandomization    = 500;
cfg.ivar                = 2;
cfg.uvar                = 1;
cfg.parameter           = 'powspctrm';
cfg.design              = design;
cfg.statistic           = 'ft_statfun_depsamplesT';  
cfg.tail                = 0;
cfg.correcttail        = 'prob';
stat                    = ft_freqstatistics(cfg,freq,null_hyp);
hipp_t = stat;

%% Repeat for Perms
% reshape source data
source_pac = reshape(source.pow,[size(source.pow,1) source.dim]);
source_pos_inside = source.pos(source.inside,:);

% cycle through each non-hippocampal voxel
square_t = [];
for v = 1 : size(source_pos_inside,1)
    
    % confirm "v" is outside hipp.
    if any(ismember(idx.hippocampus,v)); continue; end
    vp = source_pos_inside(v,:);
    
    % find voxel in full data
    tmp = find(all(source.pos == vp,2));
    [x,y,z] = ind2sub(source.dim,tmp);
       
    % get square pac
    spac = source_pac(:,x-1:x+1,y-1:y+1,z-1:z+1);
    spac = mean(spac(:,:),2);
    
    % update data struct
    freq.powspctrm = spac;

    % get pac
    stat = ft_freqstatistics(cfg,freq,null_hyp);
    square_t(end+1,1) = stat.stat;
end
    
% get number of instances when hipp T is less than square T, then get p-value
count = sum(hipp_t<square_t);
pval = count ./ numel(square_t);
    


