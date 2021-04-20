function [] = create_retrieval_order()

%%%
% this script balances the presentation of lures at retrieval
%%%

% load randomisation.mat
load('E:\bjg335\projects\epi_mem_demands\experiment\stimuli\randomisation.mat')

% define category names
context_cat = {'outdoor_nature','outdoor_urban','indoor_public','indoor_home'};
feature_cat = {'polkadot','chequered'};

% define image numbers
n_img	= 128;
n_cont	= n_img ./ numel(context_cat);
n_feat	= n_img ./ numel(feature_cat);

% define number of iterations
n_it = 100;

% define number of blocks
n_blk = 4;

% cycle through each iteration
for it = 1 : n_it
    
    % cycle through each blk
    for blk = 1 : n_blk
        
        % cycle through each stim type
        for stim = 1 : 2
            
            % get all stims for this block
            all_stim{1,1} = randomisation{it,blk}(:,stim); % BUG: need to randomise here!
            
            % clear empty stim cell
            all_stim{1,1} = all_stim{1,1}(~cellfun(@isempty,(all_stim{1,1})));
            
            % randomise stim order
            all_stim{1,1} = all_stim{1,1}(randperm(numel(all_stim{1,1})));
            
            % create buffer for used stims
            all_stim{2,1} = ones(size(all_stim{1,1}));
            
            % cycle through each trial
            for trl = 1 : size(randomisation{1},1)
                
                % define correct item position
                pos = randperm(3);
                
                % add correct stimulus
                ret_ord{it,blk,stim}{trl,pos(1)} = randomisation{it,blk}{trl,stim};
                
                % add first lure
                [ret_ord{it,blk,stim}{trl,pos(2)},all_stim] = add_img(ret_ord{it,blk,stim}(trl,:),all_stim);

                % add second lure
                [ret_ord{it,blk,stim}{trl,pos(3)},all_stim] = add_img(ret_ord{it,blk,stim}(trl,:),all_stim);
                
                if sum(cellfun(@isempty,ret_ord{it,blk,stim}(trl,:))) > 1
                    error('help!')
                end
            end
        end
    end
end

"hello"

end

function [img,all_stim] = add_img(select_img,all_stim)

% if there are no used images, go nuts
if all(cellfun(@isempty,select_img)==1)
    
    % select random integer based on number of active images
    ri = randi(sum(all_stim{2,1}),1);
    
    % translate random integer to index
    all_idx = find(all_stim{2,1}==1);
    idx     = all_idx(ri);
    
    % get image
    img = all_stim{1,1}{idx,1};
    
    % change state of image
    all_stim{2,1}(idx,1) = 0;
    
% if there are two used images, select empty
elseif sum(cellfun(@isempty,select_img)==0)==2
    img = [];

% if there is one used image
else
    
    % get used image
    uimg = select_img(cellfun(@isempty,select_img)==0);
      
    % set used image state to zero
    uidx = ismember(all_stim{1,1},uimg);
    all_stim{2,1}(uidx,1) = 0;
    
    % reset states if all zero
    if sum(all_stim{2,1}) == 0
        all_stim{2,1} = ones(size(all_stim{2,1}));
        
        % get used image
        uimg = select_img(cellfun(@isempty,select_img)==0);

        % set used image state to zero
        uidx = ismember(all_stim{1,1},uimg);
        all_stim{2,1}(uidx,1) = 0;
    end

    % select random integer based on number of active images
    ri = randi(sum(all_stim{2,1}),1);
    
    % translate random integer to index
    all_idx = find(all_stim{2,1}==1);
    idx     = all_idx(ri);
    
    % get image
    img = all_stim{1,1}{idx,1};
    
    % change state of image
    all_stim{2,1}(idx,1) = 0;
    
end


% reset states if all zero
if sum(all_stim{2,1}) == 0

    % reset all_stim
    all_stim{2,1} = ones(size(all_stim{2,1}));

end

end
