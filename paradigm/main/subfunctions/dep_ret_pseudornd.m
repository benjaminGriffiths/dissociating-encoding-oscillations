function ret_prnd = int_ret_pseudornd(enc_prnd)

% This function will produce a pseudo-randomised distribution of trials for
% the epi_mem_demands experiment.

%% Run
% cycle through each block
for blk = 1 : numel(enc_prnd)
    
    % add encoding trial numbers
    ret_prnd{blk,1}(:,1) = cellstr(num2str((1:size(enc_prnd{blk},1))','%02.0f'));
    
    % define feature combinations
    ret_prnd{blk,1}(:,2) = define_first_items(enc_prnd{blk},'feature');
    ret_prnd{blk,1}(:,3) = define_second_items(enc_prnd{blk},'feature');
    ret_prnd{blk,1}(:,4) = define_third_items(ret_prnd{blk,1}(:,2:3),'feature');
    
    % define context combinations
    ret_prnd{blk,1}(:,5) = define_first_items(enc_prnd{blk},'context');
    ret_prnd{blk,1}(:,6) = define_second_items(enc_prnd{blk},'context');
    ret_prnd{blk,1}(:,7) = define_third_items(ret_prnd{blk,1}(:,5:6),'context');
        
    % randomise within-trial order
    for i = 1 : size(ret_prnd{blk,1},1)
        ret_prnd{blk,1}(i,2:4) = ret_prnd{blk,1}(i,randperm(3)+1);
        ret_prnd{blk,1}(i,5:7) = ret_prnd{blk,1}(i,randperm(3)+4);
    end
end

% randomise between-trial order
for blk = 1 : numel(ret_prnd)
    j = randperm(size(ret_prnd{blk,1},1));
    ret_prnd{blk,1} = ret_prnd{blk,1}(j,:);
end

end

function rnd_out = define_first_items(rnd_in,stim_type)

% define image labels and indices based on specified stimulus type
switch stim_type
    case 'context'
        img_idx   = 3;
    case 'feature'
        img_idx   = 2;
end

% select first item ("correct")
rnd_out = rnd_in(:,img_idx);

end

function rnd_out = define_second_items(rnd_in,stim_type)

% define output
rnd_out = cell(size(rnd_in,1),1);

% define image labels and indices based on specified stimulus type
switch stim_type
    case 'context'
        img_idx   = 3;
    case 'feature'
        img_idx   = 2;
end

% get used images and shuffle
uimg = rnd_in((cellfun(@isempty,(rnd_in(:,img_idx)))==0),img_idx);
uimg = uimg(randperm(numel(uimg)),:);

% select second item (empty for those with images position one, else rand)
null_idx    = cellfun(@isempty,(rnd_in(:,img_idx)));
rnd_out(null_idx,1) = uimg(randperm(numel(uimg)),:);

end

function rnd_out = define_third_items(rnd_in,stim_type)

% define output
rnd_out = cell(size(rnd_in,1),1);

% define image labels and indices based on specified stimulus type
switch stim_type
    case 'context'
        img_label = {'indoor','outdoor'};
    case 'feature'
        img_label = {'polkadot','chequered'};
end

% get used images, split into subcategories and replicate once
tmp = unique(rnd_in((cellfun(@isempty,rnd_in)==0)));
for i = 1 : numel(img_label)
    img.(img_label{i}) = tmp(strncmpi(tmp,img_label{i},4));
    img.(img_label{i}) = repmat(img.(img_label{i}),[2,1]);
end

% attempt to find a combination where are all trials consist of
% non-matching pairs of stimuli
failed_pairing = true;
while failed_pairing
    
    % cycle through subcategories
    for i = 1 : numel(img_label)
        
        % randomise images
        img.(img_label{i}) = img.(img_label{i})(randperm(numel(img.(img_label{i}))));
        
        % get index of match category images
        idx = any(strncmpi(rnd_in,img_label{i},4),2);
        
        % append to rnd_out
        rnd_out(idx,1) = img.(img_label{i});
        
    end
    
    % check to see if all items per trial are unique
    unique_comb = false(size(rnd_out));
    for j = 1 : size(rnd_out,1)
        unique_comb(j,1) = ~strcmpi(rnd_out{j,1},rnd_in{j,1}) & ~strcmpi(rnd_out{j,1},rnd_in{j,2});
    end
    
    % test
    if all(unique_comb)
        failed_pairing = false;
    end   

end
end
