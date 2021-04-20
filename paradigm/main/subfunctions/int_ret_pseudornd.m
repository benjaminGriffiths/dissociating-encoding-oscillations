function cfg = int_ret_pseudornd(cfg,log)

% This function will produce a pseudo-randomised distribution of trials for
% the epi_mem_demands experiment.

% extract encoding order of current block
enc_prnd = cfg.rand.encoding(cfg.trialCount:sum(log.block_size),:);

% get number of subblocks
nsub = size(enc_prnd,1)./24;

%% Run
% cycle through subblocks
for s = 1 : nsub %#ok<BDSCI>

    % get encoding items of interest
    enc_ioi = enc_prnd(1+(24*(s-1)):(24*s),:);
    
    % empty tmp_prnd
    tmp_prnd = {};
    
    % add encoding trial numbers
    tmp_prnd(:,1) = cellstr(num2str(((1:size(enc_ioi,1))+(cfg.trialCount-1)+(24*(s-1)))','%02.0f'));

    % define feature combinations
    tmp_prnd(:,2) = define_first_items(enc_ioi,'feature');
    tmp_prnd(:,3) = define_second_items(enc_ioi,'feature');
    tmp_prnd(:,4) = define_third_items(tmp_prnd(:,2:3));

    % define context combinations
    tmp_prnd(:,5) = define_first_items(enc_ioi,'context');
    tmp_prnd(:,6) = define_second_items(enc_ioi,'context');
    tmp_prnd(:,7) = define_third_items(tmp_prnd(:,5:6));

    % randomise within-trial order
    for i = 1 : size(tmp_prnd,1)
        tmp_prnd(i,2:4) = tmp_prnd(i,randperm(3)+1);
        tmp_prnd(i,5:7) = tmp_prnd(i,randperm(3)+4);
    end
    
    % store subblock prnd
    sblk_prnd{s} = tmp_prnd; %#ok<AGROW>
end
    
% concatenate subblock prnd and randomise between-trial order
ret_prnd    = cat(1,sblk_prnd{:});
j           = randperm(size(ret_prnd,1));
ret_prnd    = ret_prnd(j,:);

%%
% add order to cfg.rand.retrieval
if isfield(cfg.rand,'retrieval')
    cfg.rand.retrieval(end+1:end+size(ret_prnd,1),:) = ret_prnd;
else
    cfg.rand.retrieval = ret_prnd;
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
        img_typ   = {'out','ind'};
    case 'feature'
        img_idx   = 2;
        img_typ   = {'pol','che'};
end

% get used images and split by subcategory
uimg = rnd_in(:,img_idx);
uimg_typ1 = uimg(strncmpi(uimg,img_typ{1},3),1);
uimg_typ2 = uimg(strncmpi(uimg,img_typ{2},3),1);

% cycle through each trial and add stimulus of differing category
for trl = 1 : size(rnd_out,1)
    if strncmpi(rnd_in{trl,img_idx},img_typ{1},3)
        idx            = randperm(numel(uimg_typ2),1);
        rnd_out{trl,1} = uimg_typ2{idx,1};
        uimg_typ2(idx,:) = [];
    else
        idx            = randperm(numel(uimg_typ1),1);
        rnd_out{trl,1} = uimg_typ1{idx,1};
        uimg_typ1(idx,:) = [];
    end
end

end

function rnd_out = define_third_items(rnd_in)

% get used images
uimg = unique(rnd_in);

% start iterative fit
bad_fit = true;
while bad_fit

    % create a random order and add to rnd_in
    rnd_out = uimg(randperm(numel(uimg)));
    
    % check fit 
    if any(cellfun(@strcmpi,rnd_out,rnd_in(:,1))) || any(cellfun(@strcmpi,rnd_out,rnd_in(:,2)))
        bad_fit = true;
    else
        bad_fit = false;
    end

end
end
