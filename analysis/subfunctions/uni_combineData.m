function freq_out = uni_combineData(freq_cell,parameters)

% get number of cell
ni = numel(freq_cell);

% get number of parameters to combine
if iscell(parameters); np = numel(parameters); 
else np = 1; parameters = {parameters};
end

% create output structure
freq_out = rmfield(freq_cell{1},parameters);
freq_out.dimord = 'subj_chan_freq_time';
freq_out.cfg = [];

% xcycle through parameters
for p = 1 : np
    
    % predefine combine matrices
    freq_out.(parameters{p}) = nan([ni,size(freq_cell{1}.(parameters{p}))]);
        
    % cycle through reps
    for i = 1 : ni
        
        % combine parameters
        freq_out.(parameters{p})(i,:,:,:) = freq_cell{i}.(parameters{p});
    end    
end




