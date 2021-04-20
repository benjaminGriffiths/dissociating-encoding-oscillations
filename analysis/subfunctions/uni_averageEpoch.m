function avg_data = uni_averageEpoch(data)

% extract trial numbers
for trl = 1 : numel(data.trialinfo)
    trl_no(trl) = data.trialinfo{trl}.trl_num_enc;
    switch data.trialinfo{trl}.stimulus
        case 'retrieve'; trl_type(trl) = 2;
        case 'associate'; trl_type(trl) = 2;
        otherwise; trl_type(trl) = 1;
    end
end
data.cfg=[];

% segregate trial types
cfg         = [];
cfg.trials  = find(trl_type == 2);
safe_data   = ft_selectdata(cfg,data);

epoch_data = data;
epoch_data.powspctrm = data.powspctrm(trl_type == 1,:,:,:);
epoch_data.trialinfo = data.trialinfo(trl_type == 1);
clear data

% get all unique numbers in remaining data
trl_no = trl_no(trl_type==1);
uni_trl = unique(trl_no);

% cycle through each number
for i = 1:numel(uni_trl)
    sum_uni(i) = sum(trl_no==uni_trl(i));
end

% get trial number of unique trios
idx = uni_trl(sum_uni==3);

% duplicate data structure
avg_data = rmfield(epoch_data,{'powspctrm','trialinfo'});
avg_data.powspctrm = zeros(numel(idx),size(safe_data.powspctrm,2),size(safe_data.powspctrm,3),size(safe_data.powspctrm,4));

% cycle through all instances where three trials are present
for i = 1 : numel(idx)
    
    % extract trialinfo
    ti = {};
    tidx = find(trl_no == idx(i));
    for j = 1:numel(tidx)
        ti{j} = epoch_data.trialinfo{tidx(j)};
    end
    
    % edit trialinfo
    new_info = ti{1};
    new_info.stimulus = 'percept';
    new_info.stim1 = ti{1}.stimulus;
    new_info.stim2 = ti{2}.stimulus;
    new_info.stim3 = ti{3}.stimulus;
    
    % select and average over trials
    pow = mean(epoch_data.powspctrm(trl_no == idx(i),:,:,:));
    
    % add data to structure
    avg_data.powspctrm(i,:,:,:) = pow;
    avg_data.trialinfo{i,1} = new_info;
end

% concatenate data
avg_data.cfg = [];

