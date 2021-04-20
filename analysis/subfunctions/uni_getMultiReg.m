function output = uni_getMultiReg(freq,motion,baseCorrect)

% extract power
y = freq.powspctrm(:,:);
dims = size(freq.powspctrm);

% calculate ERD (for constant analysis)
if baseCorrect
    avgbase = repmat(mean(freq.powspctrm(:,:,:,freq.time>-0.25&freq.time<0),4),[1 1 1 numel(freq.time)]);
    yi = freq.powspctrm - avgbase;
    yi = yi(:,:);
else
    yi = y;
end

% add single dimensions if required
if numel(dims)<4
    nmiss = 4 - numel(dims);
    dims = [dims ones(1,nmiss)];
end

% extract trialinfo 
X = ones(size(y,1),4);
for trl = 1 : size(y,1)
    X(trl,2) = freq.trialinfo{trl}.mem_score;
    X(trl,3) = double(strcmpi(freq.trialinfo{trl}.mem_feat,'target'));
    X(trl,4) = double(strcmpi(freq.trialinfo{trl}.mem_scene,'target'));
end

% reshape motion
n_nuisance = size(motion,ndims(motion));
motion = permute(motion,[ndims(motion) 1:ndims(motion)-1]);
motion = permute(motion(:,:,:),[2 3 1]);

% replicate motion if requierd
if size(motion,2) == 1
    motion = repmat(motion,[1 size(y,2)]);
end

% prepare result
linft = zeros(size(y,2),size(X,2)+n_nuisance);

% cycle through each channel
for chan = 1 : size(y,2)

    %% Run Constant Model (does measure differ from chance?)
    % extract channel specific nuisance regressors
    chan_nuisance = squeeze(motion(:,chan,:));
    
    % create predictor matrix
    Xi = cat(2,ones(size(chan_nuisance,1),1),chan_nuisance(:,1));
    Xi(:,2:end) = zscore(Xi(:,2:end),[],1);
       
    % get model variance
    modcov = inv(Xi'*Xi);

    % get linear fit
    beta = Xi\yi(:,chan);             % get betas
    n = size(yi,1);                  % get number of samples
    r = yi(:,chan) - (Xi * beta);     % get error of fit
    SSE = sum(r.^2);                % calculate sum of squared errors
    MSE = SSE ./ (n-size(Xi,2));     % calculate mean squared error
    SE = diag(sqrt(MSE*modcov)); % calculate standard error of each beta
    t = beta ./ SE;                 % calculate t-stat
    linft(chan,1) = t(1);    % store
    
    %% Run Memory Model (does measure differ based on memory?)
    % extract channel specific nuisance regressors
    chan_nuisance = squeeze(motion(:,chan,:));
    
    % add motion/hitmiss regressor
    Xi = X;
    Xi(:,end+1:end+size(chan_nuisance,2)) = chan_nuisance;
    Xi(:,2:end) = zscore(Xi(:,2:end),[],1);
       
    % get model variance
    modcov = inv(Xi'*Xi);

    % get linear fit
    beta = Xi\y(:,chan);             % get betas
    n = size(y,1);                  % get number of samples
    r = y(:,chan) - (Xi * beta);     % get error of fit
    SSE = sum(r.^2);                % calculate sum of squared errors
    MSE = SSE ./ (n-size(Xi,2));     % calculate mean squared error
    SE = diag(sqrt(MSE*modcov)); % calculate standard error of each beta
    t = beta ./ SE;                 % calculate t-stat
    linft(chan,2:end) = t(2:end);    % store
end

% cycle through each beta
pow = zeros(dims(2),dims(3),dims(4),4);
for b = 1 : size(linft,2)
    pow(:,:,:,b) = reshape(linft(:,b),[dims(2) dims(3) dims(4)]);
end

% prepare output 
output = cell(1,size(linft,2));
for i = 1 : size(linft,2)
    output{i} = struct('label',{freq.label},'freq',freq.freq,'time',freq.time,...
                       'powspctrm',pow(:,:,:,i),'cfg',[],'dimord','chan_freq_time');
end