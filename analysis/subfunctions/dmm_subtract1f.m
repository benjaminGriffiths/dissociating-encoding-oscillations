function freq = dmm_subtract1f(freq)

% This function estimates and subtracts the fractal property of a power 
% spectrum. The [freq] input must match a Fieldtrip formatted
% time-frequency data structure.

% extract parameters
f   = freq.freq;
t   = freq.time;
pow = freq.powspctrm;
trialinfo  = freq.trialinfo;

% get memory conditions
mem_performance = zeros(size(trialinfo));
for trl = 1 : numel(trialinfo)
    mem_performance(trl,1) = trialinfo{trl}.mem_score;
end

% create empty matrix for corrected power
pow_corr = zeros(size(pow));

% cycle through memory conditions
%figure('position',[100 100 300 500]); hold on
for i = 1 : numel(unique(mem_performance))
    
    % get index of trials in memory condition
    idx = mem_performance == i-1;    
    
    % subtract 1/f from trials
    pow_out = internal_subtract1f(f,pow(idx,:,:,:),t);
    
    % add to corrected power
    pow_corr(idx,:,:,:) = pow_out;
    
%     % plot corrected power
%     subplot(3,1,i); hold on; axis xy tight
%     imagesc(t,f,squeeze(mean(mean(pow_corr,2),1)));
%     colorbar();
end

% add power into frequency structure
freq.powspctrm = pow_corr;
end

function pow_out = internal_subtract1f(f,pow,t)

% % store original input
% org_input.f = f;
% org_input.pow = pow;

% average power over trials and post-stim power
pow_avg = squeeze(nanmean(nanmean(pow(:,:,:,t>0),4),1));

% get dimenesions of power
avg_dim = size(pow_avg);

% fit 1/f
logf    = squeeze(log10(f));
logpow  = squeeze(log10(pow_avg));
logpow_raw = squeeze(log10(pow));
%beta    = zeros(size(logpow,1),1);

% cycle through each channel
for chan = 1 : size(logpow,1)
   
    % get temporary power and frequency
    tmp_f   = logf;
    tmp_pow = logpow(chan,:);
    
    % iterate
    while true
    
        % get fit
        b = [ones(size(tmp_f))' tmp_f'] \ tmp_pow';
        linft = tmp_f*b(2) + b(1);

        % subtract fit
        firstpass = tmp_pow - linft;

        % get error (the mean power of all frequencies less than zero)
        erange = mean(firstpass(firstpass<0));
        
        % find all postive values greater than the error
        eidx   = firstpass>abs(erange);
        
        % if no error or if more than half of the frequencies have been removed
        if (sum(eidx)) == 0 || (numel(tmp_f) <= numel(logf)/2)
        
            % recompute fit using all data
            linft = logf*b(2) + b(1);
            
            % replicate linft for each trial and each timepoint
            linft = permute(repmat(linft,[size(logpow_raw,1) 1 1 size(logpow_raw,4)]),[1 3 2 4]);
            
            % subtract fit
            logpow_raw(:,chan,:,:) = logpow_raw(:,chan,:,:) - linft;
               
            % save output 
            %beta(trl,1) = b(2);
            break
                        
         % otherwise, remove freqencies that exceed the error threshold 
        else
            tmp_pow = tmp_pow(eidx==0);
            tmp_f   = tmp_f(eidx==0);
            
        end
    end
end

% convert pow
pow_out = 10.^logpow_raw;
%frac_out = repmat(beta,[1 size(freq.powspctrm,2)]);
end
