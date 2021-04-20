function int_loadScreen(cfg,condition)

% restrict to experimenter key
RestrictKeysForKbCheck(cfg.resp.experimenter);

% check condition
if strcmpi(condition,'encoding')
    
    for i = 5 : -1 : 1
        DrawFormattedText(cfg.screen.w1,sprintf('Your next encoding run will begin in %d seconds',i),'center','center',[0 0 0]);
        Screen('Flip',cfg.screen.w1); % flip
        WaitSecs(1);
    end
    
elseif strcmpi(condition,'retrieval')
    
    for i = 5 : -1 : 1
        DrawFormattedText(cfg.screen.w1,sprintf('Your next retrieval run will begin in %d seconds',i),'center','center',[0 0 0]);
        Screen('Flip',cfg.screen.w1); % flip
        WaitSecs(1);
    end
    
elseif strcmpi(condition,'distractor')
    
    for i = 10 : -1 : 1
        DrawFormattedText(cfg.screen.w1,sprintf('How often does the fixation cross change to dark grey?\n\nStarting in %d seconds',i),'center','center',[0 0 0]);
        Screen('Flip',cfg.screen.w1); % flip
        WaitSecs(1);
    end
    
elseif strcmpi(condition,'resting_state')
    
    for i = 5 : -1 : 1
        DrawFormattedText(cfg.screen.w1,'Sit back and relax','center','center',[0 0 0]);
        Screen('Flip',cfg.screen.w1); % flip
        WaitSecs(1);
    end

end