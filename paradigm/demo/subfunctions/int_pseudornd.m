function prnd = int_enc_pseudornd
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
img.animate     = dir('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_object\animate*.jpg');
img.inanimate   = dir('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_object\inanimate*.jpg');
img.polka       = dir('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_feature\polkadot*.jpg');
img.check       = dir('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_feature\chequered*.jpg');
img.indoor      = dir('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_context\indoor*.jpg');
img.outdoor     = dir('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\image_context\outdoor*.jpg');

%% Define Condition Values
cv(1,:)   = [1 0 0 4]; % animate    / null  / null      / 8 trials
cv(2,:)   = [2 0 0 4]; % inanimate  / null  / null      / 8 trials
cv(3,:)   = [1 1 0 1]; % animate    / polka / null      / 2 trials
cv(4,:)   = [2 1 0 1]; % inanimate  / polka / null      / 2 trials
cv(5,:)   = [1 2 0 1]; % animate    / check / null      / 2 trials
cv(6,:)   = [2 2 0 1]; % inanimate  / check / null      / 2 trials
cv(7,:)   = [1 0 1 1]; % animate    / null  / indoor    / 2 trials
cv(8,:)   = [2 0 1 1]; % inanimate  / null  / indoor    / 2 trials
cv(9,:)   = [1 0 2 1]; % animate    / null  / null      / 2 trials
cv(10,:)  = [2 0 2 1]; % inanimate  / null  / null      / 2 trials
cv(11,:)  = [1 1 1 1]; % animate    / polka / indoor    / 2 trials
cv(12,:)  = [2 1 1 1]; % inanimate  / polka / indoor    / 2 trials
cv(13,:)  = [1 2 1 1]; % animate    / check / indoor    / 2 trials
cv(14,:)  = [2 2 1 1]; % inanimate  / check / indoor    / 2 trials
cv(15,:)  = [1 1 2 1]; % animate    / polka / outdoor   / 2 trials
cv(16,:)  = [2 1 2 1]; % inanimate  / polka / outdoor   / 2 trials
cv(17,:)  = [1 2 2 1]; % animate    / check / outdoor   / 2 trials
cv(18,:)  = [2 2 2 1]; % inanimate  / check / outdoor   / 2 trials

n_rep = 2; % number of times this order needs to be repeated per block

%% Create Order
% cycle through first two blocks
for blk = 1 : 2; [prnd{blk},img] = create_block(cv,img,n_rep); end

% replace remaining object images with those that have already been used
uimg	= [prnd{1}(:,1); prnd{2}(:,1)]; % get used images
ani_tmp = uimg(strncmpi(uimg,'ani',3));
ina_tmp = uimg(strncmpi(uimg,'ina',3));

% cycle through each item and add to struct
for i = 1 : numel(ani_tmp); img.animate(i,1).name = ani_tmp{i,1}; img.inanimate(i,1).name = ina_tmp{i,1}; end

% cycle through second two blocks
for blk = 3 : 4; [prnd{blk},img] = create_block(cv,img,n_rep); end

end

function [pr,img] = create_block(cv,img,n_rep)

pr = {};

% cycle through each repetition
for r = 1 : n_rep
    
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
            if cv(i,2) ~= 0  % if feature is required
                
                % choose random feature
                feat_idx        = randi(numel(img.(img.category{2,cv(i,2)})));
                tmp_pr{end,2} = img.(img.category{2,cv(i,2)})(feat_idx,1).name;
                
                % remove selected feature from choice
                img.(img.category{2,cv(i,2)})(feat_idx,:) = [];
                
            else
                tmp_pr{end,2} = [];
                
            end
            
            % --- choose context --- %
            if cv(i,3) ~= 0  % if feature is required
                
                % choose random feature
                cnxt_idx        = randi(numel(img.(img.category{3,cv(i,3)})));
                tmp_pr{end,3} = img.(img.category{3,cv(i,3)})(cnxt_idx,1).name;
                
                % remove selected feature from choice
                img.(img.category{3,cv(i,3)})(cnxt_idx,:) = [];
                
            else
                tmp_pr{end,3} = [];
                
            end
            
        end
    end
    
    % randomise trial order
    tmp_pr = tmp_pr(randperm(size(tmp_pr,1)),:);
    
    % add to pr
    pr(1+((r-1)*size(tmp_pr,1)) : r*size(tmp_pr,1),:) = tmp_pr;
end

end
