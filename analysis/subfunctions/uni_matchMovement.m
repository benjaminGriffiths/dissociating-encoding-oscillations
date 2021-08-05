function dp_out = uni_matchMovement(ti,dp);

% create output vector
dp_out = nan(size(ti));

% cycle through each trial
for trl = 1 : numel(ti)
    
    % get trial details
    if strncmpi(ti{trl}.stimulus,'ani',3) || strncmpi(ti{trl}.stimulus,'ina',3) || strncmpi(ti{trl}.stimulus,'per',3)
        stim_val = 1;
        trl_no = ti{trl}.trl_num_enc;
    elseif strncmpi(ti{trl}.stimulus,'pol',3) || strncmpi(ti{trl}.stimulus,'che',3)
        stim_val = 2;
        trl_no = ti{trl}.trl_num_enc;
    elseif strncmpi(ti{trl}.stimulus,'ind',3) || strncmpi(ti{trl}.stimulus,'out',3)
        stim_val = 4;
        trl_no = ti{trl}.trl_num_enc;
    elseif strncmpi(ti{trl}.stimulus,'ass',3)
        stim_val = 8;
        trl_no = ti{trl}.trl_num_enc;
    elseif strncmpi(ti{trl}.stimulus,'ret',3)
        stim_val = 16;
        trl_no = ti{trl}.trl_num_ret;
    end
    
    % construct value and find in [dp]
    search_val = trl_no*1000 + stim_val;
    idx = dp(:,2) == search_val;
    
    % add matching movement value to output
    dp_out(trl) = dp(idx,1);
end

end