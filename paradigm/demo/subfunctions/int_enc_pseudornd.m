function prnd = int_enc_pseudornd(cfg)
% This function will produce a pseudo-randomised distribution of trials for
% the epi_mem_demands experiment. Below is a schematic of the subcategories
% that need to be balanced and their conditions values.
%
%      NULL          LOW LOAD (Feat)         LOW LOAD (Context)                ----- HIGH LOAD -----
%       |                  |                     /        \                   /                     \
%      / \               /   \                4 In      4 Out              8 In                   8 Out
%     /   \            /       \                |          |            /        \              /        \
%    /     \        4 Pol      4 Check          |          |         4 Pol      4 Check       4 Pol     4 Check
%   /       \      /     \      /    \        /   \      /   \       /    \      /    \       /    \     /    \
% 8 Ani  8 Inan  2 An  2 In   2 An 2 In     2 An 2 In   2 An 2 In   2 An 2 In   2 An 2 In   2 An 2 In   2 An 2 In
%
%  (1)     (2)    (3)   (4)    (5)  (6)      (7)  (8)    (9)  (10)   (11) (12)   (13)  (14)  (15)  (16)  (17) (18)

%% Load Image Data
img.category    = {'animate','inanimate';'polka','check';'indoor','outdoor'};
img.animate     = dir([cfg.wdir,'stimuli\image_object\animate*.jpg']);
img.inanimate   = dir([cfg.wdir,'stimuli\image_object\inanimate*.jpg']);
img.polka       = dir([cfg.wdir,'stimuli\image_feature\polkadot*.jpg']);
img.check       = dir([cfg.wdir,'stimuli\image_feature\chequered*.jpg']);
img.indoor      = dir([cfg.wdir,'stimuli\image_context\indoor*.jpg']);
img.outdoor     = dir([cfg.wdir,'stimuli\image_context\outdoor*.jpg']);

%% Define Condition Values
cv(1,:)  = [1 1 1 3]; % animate    / polka / indoor    / 2 trials
cv(2,:)  = [2 1 1 3]; % inanimate  / polka / indoor    / 2 trials
cv(3,:)  = [1 2 1 3]; % animate    / check / indoor    / 2 trials
cv(4,:)  = [2 2 1 3]; % inanimate  / check / indoor    / 2 trials
cv(5,:)  = [1 1 2 3]; % animate    / polka / outdoor   / 2 trials
cv(6,:)  = [2 1 2 3]; % inanimate  / polka / outdoor   / 2 trials
cv(7,:)  = [1 2 2 3]; % animate    / check / outdoor   / 2 trials
cv(8,:)  = [2 2 2 3]; % inanimate  / check / outdoor   / 2 trials

%% Create Order
% cycle through first five blocks
for blk = 1 : 5; [prnd{blk},img] = create_block(cv,img); end

% define selection order for stimulus reuse in last blocks - this avoids
% stimulus reuse within chunks and potenial interference
sel_crit = [1 2 3; 1 2 3; 2 3 1; 2 3 1; 3 1 2; 3 1 2]';

% cycle through last five blocks, being sure to only select items from
% first three blocks prior
for blk = 6 : 8
    
    % define new image struct
    img_reuse.category    = {'animate','inanimate';'polka','check';'indoor','outdoor'};
        
    % extract images of interest and randomise
    ioi = {}; 
    ioi(end+1:end+12,1) = prnd{sel_crit(blk-5,1)}(strncmpi(prnd{sel_crit(blk-5,1)},'ani',3));
    ioi(end+1:end+12,1) = prnd{sel_crit(blk-5,2)}(strncmpi(prnd{sel_crit(blk-5,2)},'ina',3));
    ioi(end+1:end+12,1) = prnd{sel_crit(blk-5,3)}(strncmpi(prnd{sel_crit(blk-5,3)},'pol',3));
    ioi(end+1:end+12,1) = prnd{sel_crit(blk-5,4)}(strncmpi(prnd{sel_crit(blk-5,4)},'che',3));
    ioi(end+1:end+12,1) = prnd{sel_crit(blk-5,5)}(strncmpi(prnd{sel_crit(blk-5,5)},'ind',3));
    ioi(end+1:end+12,1) = prnd{sel_crit(blk-5,6)}(strncmpi(prnd{sel_crit(blk-5,6)},'out',3));
    ioi = ioi(randperm(numel(ioi)));
    
    % cycle through each item
    for i = 1 : 12
        
        % cycle through each category
        for j = 1 : numel(img_reuse.category)
            
            % get index of image
            idx = find(strncmpi(ioi,(img_reuse.category{j}),3),1);
            
            % add image to struct
            img_reuse.(img_reuse.category{j})(i,1).name = char(ioi{idx});
            
            % remove image from ioi
            ioi(idx,:) = [];
            
        end
    end
    
    prnd{blk} = create_block(cv,img_reuse); 
end

% collapse into single cell matrix
prnd = cat(1,prnd{:});

end

function [pr,img] = create_block(cv,img)

% create cell to contain details
tmp_pr = {};

% cycle through each condition
for i = 1 : size(cv,1)

    % cycle through each trial of that condition
    for j = 1 : cv(i,4)

        % --- choose object --- %
        obj_idx         = randi(numel(img.(img.category{1,cv(i,1)})));
        tmp_pr{end+1,1} = img.(img.category{1,cv(i,1)})(obj_idx,1).name;

        % remove selected object from choice
        img.(img.category{1,cv(i,1)})(obj_idx,:) = [];

        % --- choose feature --- %
        feat_idx        = randi(numel(img.(img.category{2,cv(i,2)})));
        tmp_pr{end,2} = img.(img.category{2,cv(i,2)})(feat_idx,1).name;

        % remove selected feature from choice
        img.(img.category{2,cv(i,2)})(feat_idx,:) = [];

        % --- choose context --- %
        cnxt_idx        = randi(numel(img.(img.category{3,cv(i,3)})));
        tmp_pr{end,3} = img.(img.category{3,cv(i,3)})(cnxt_idx,1).name;

        % remove selected feature from choice
        img.(img.category{3,cv(i,3)})(cnxt_idx,:) = [];

    end
end

% randomise trial order
tmp_pr = tmp_pr(randperm(size(tmp_pr,1)),:);

% add to pr
pr = tmp_pr;

end
