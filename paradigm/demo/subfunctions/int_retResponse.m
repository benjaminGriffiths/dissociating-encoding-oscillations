function log = int_retResponse(cfg,log,target_type)

% restrict response keys
RestrictKeysForKbCheck(cfg.resp.participant);

% define trial at encoding
trl_at_enc = str2double(cfg.rand.retrieval(cfg.trialCount,1));
log.task_raw{trl_at_enc,4} = cfg.trialCount;

% define index of target type
switch target_type
    case 'feature'
        stim_idx = 1;
        stim_folder = 'image_feature';
        stimulus = cfg.rand.retrieval(cfg.trialCount,2:4);
        
    case 'context'
        stim_idx = 2;
        stim_folder = 'image_context';
        stimulus = cfg.rand.retrieval(cfg.trialCount,5:7);
        
end

% find correct image
left_correct    = strcmpi(stimulus{1},log.task_raw{trl_at_enc,stim_idx+1})...
                  || all(cellfun(@isempty,({stimulus{1},log.task_raw{trl_at_enc,stim_idx+1}})));
down_correct    = strcmpi(stimulus{2},log.task_raw{trl_at_enc,stim_idx+1})...
                  || all(cellfun(@isempty,({stimulus{2},log.task_raw{trl_at_enc,stim_idx+1}})));
right_correct   = strcmpi(stimulus{3},log.task_raw{trl_at_enc,stim_idx+1})...
                  || all(cellfun(@isempty,({stimulus{3},log.task_raw{trl_at_enc,stim_idx+1}})));

% draw stimulus
key_pos = 1;
t1      = int_presentation(cfg,stim_folder,stimulus,key_pos,[0 0 0]);
          
% define int_resp variable
t3 = [];

% wait for response
while true
	
    % check for response   
    [resp,t2] = int_getResponse(cfg);
    if isempty(t3); t3=t2; end

    % if left key, then move cursor
    if resp == 1
                
        % update cursor position
        if key_pos == 1; key_pos = 2;
        elseif key_pos == 2; key_pos = 3;
        else; key_pos = 1;
        end
        
        % redraw screen with with cursor in new position
        int_presentation(cfg,stim_folder,stimulus,key_pos,[0 0 0]);
        
    % if right key, then select response
    elseif resp == 2
                
        % redraw screen with green response
        int_presentation(cfg,stim_folder,stimulus,key_pos,[255 0 0]);
        
        % switch to pressed key
        switch key_pos
            
            % if left
            case 1
                log.task_raw{trl_at_enc,12+((stim_idx-1).*4)} = 'left';
                if left_correct
                    log.task_raw{trl_at_enc,9+((stim_idx-1).*4)} = 'target'; 
                else
                    log.task_raw{trl_at_enc,9+((stim_idx-1).*4)} = 'lure'; 
                end
                                
            % if middle
            case 2
                log.task_raw{trl_at_enc,12+((stim_idx-1).*4)} = 'centre';
                if down_correct
                    log.task_raw{trl_at_enc,9+((stim_idx-1).*4)} = 'target'; 
                else
                    log.task_raw{trl_at_enc,9+((stim_idx-1).*4)} = 'lure'; 
                end
                
            % if right
            case 3
                log.task_raw{trl_at_enc,12+((stim_idx-1).*4)} = 'right';
                if right_correct
                    log.task_raw{trl_at_enc,9+((stim_idx-1).*4)} = 'target'; 
                else
                    log.task_raw{trl_at_enc,9+((stim_idx-1).*4)} = 'lure';
                end
        end
        
        % add RTs
        log.task_raw{trl_at_enc,10+((stim_idx-1).*4)} = t3-t1;
        log.task_raw{trl_at_enc,11+((stim_idx-1).*4)} = t2-t1;
        
        % wait 100ms
        WaitSecs(0.1);
        
        % reenable all keys
        RestrictKeysForKbCheck([]);
        
        % exit function
        break
    end
end
end

function t1 = int_presentation(cfg,stim_folder,stimulus,key_pos,key_color)

% cycle through and draw each target
for si = 1 : numel(stimulus)
    
    img     = imresize(imread([cfg.wdir,'stimuli\',stim_folder,'\',stimulus{si}]),0.75); % read image
    im2txt  = Screen('MakeTexture',cfg.screen.w1,img); % convert image to texture
    Screen('DrawTexture',cfg.screen.w1, im2txt,[],cfg.screen.pos.ret_img(si,:)); % draw texture
    
end

% define box around target
box_pos = [cfg.screen.pos.ret_img(key_pos,1)-40,cfg.screen.pos.ret_img(key_pos,2)-40,...
           cfg.screen.pos.ret_img(key_pos,3)+40,cfg.screen.pos.ret_img(key_pos,4)+40];
       
% draw box
Screen('FrameRect',cfg.screen.w1,key_color,box_pos,4)
       
% present screen
t1 = Screen('Flip',cfg.screen.w1); % flip

end