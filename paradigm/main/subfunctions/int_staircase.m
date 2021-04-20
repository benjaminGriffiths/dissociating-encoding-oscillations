function bs = int_staircase(cfg,log)

%% Get Variables
% get performance
A  = log.task_raw(cellfun(@isempty,log.task_raw(:,8)) == 0,[8 11 14]);
Ah = sum(all(ismember(A(:,[1 2]),'target'),2) & ~ismember(A(:,3),'guess')) ./ size(A,1);
Am = sum(all(ismember(A(:,[1 2]),'lure'),2) | ismember(A(:,3),'guess')) ./ size(A,1);
Ac = Ah ./ Am;

% get block size and number of remaining trials
bs_old = log.block_size(end,1);
r_trl  = cfg.var.n_trl - (cfg.trialCount-1);

% define performance ratio thresholds
uT = 1.5;
lT = 0.75;

% define lowest common denominator
lcd = 24;

%% Check Break Conditions
% break if the number of remaining trials matches the current block size
if bs_old == r_trl; bs = bs_old; return; end

% break if the number of remaining trials is less than current block size;
% set next block size to remaining trials
if bs_old > r_trl; bs = r_trl; return; end

% break if performance is greater than upper threshold, but not enough
% trials to expand
if (Ac > uT) && (r_trl*2 < bs_old); bs = bs_old; return; end

% break if poor performance, but cannot reduce block size further
if (Ac < lT) && (bs_old == lcd); bs = bs_old; return; end

%% Run Staircase
if Ac > uT;     bs = bs_old + lcd;
elseif Ac < lT; bs = bs_old - lcd;
else;           bs = bs_old;
end

% check trials
if bs > r_trl
    bs = r_trl;
end

end

 %#ok<*BDSCI>