function freq = dmm_correctPower(bids_dir,subj,epoch,freq)
   
% define a few directories
fprintf('\ncorrecting power...\n');
subj_str = sprintf('sub-%02.0f',subj);
subj_dir = [bids_dir,'derivatives/',subj_str,'/'];   
 
% define meg file
meg_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',epoch),'_pow-raw.mat'];
      
% load data if required
if nargin < 4
    fprintf('loading data file...\n');
    load(meg_file,'freq');    
else
    fprintf('using inputted data structure...\n');
end

% cycle through the two spectra
for i = 1 : size(freq,2)

    % smooth
    cfg = [];
    cfg.fwhm_t = 0.2;
    cfg.fwhm_f = 1;
    freq{1,i} = smooth_TF_GA(cfg,freq{1,i});

    % combine gradiometers            
    cfg             = [];
    cfg.method      = 'sum';
    freq{1,i}       = ft_combineplanar(cfg,freq{1,i});

    % drop unnecessary fields
    freq{1,i} = rmfield(freq{1,i},{'cfg','cumtapcnt'});

    % average over epoch
    if epoch == 1; freq{1,i} = uni_averageEpoch(freq{1,i}); end
    
    % subtract 1/f
    freq{1,i} = dmm_subtract1f(freq{1,i});               
end

% append the two spectra
cfg             = [];
cfg.appenddim   = 'freq';
cfg.parameter   = 'powspctrm';
freq            = ft_appendfreq(cfg,freq{1,:});

% save data
fprintf('saving corrected tfr data\n')
save_file = [subj_dir,'meg/timeseries/',subj_str,'_stage-08_run-',sprintf('%02.0f',epoch),'_pow-corr.mat'];
save(save_file,'freq','-v7.3');
