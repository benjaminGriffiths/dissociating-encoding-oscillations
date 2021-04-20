function log = int_retConfidence(cfg,log)

% define trial at encoding
trl_at_enc = str2double(cfg.rand.retrieval(cfg.trialCount,1));

% define cursor position
key_pos = 1;

% draw screen
t1 = int_presentation(cfg,key_pos);

% define int_resp variable
t3 = [];

% wait for response
while true
	
    % check for response
    [resp,t2] = int_getResponse(cfg);
    if isempty(t3); t3 = t2; end
            
    % if left key, then move cursor
    if resp == 1
                
        % update cursor position
        if key_pos == 1; key_pos = 2;
        elseif key_pos == 2; key_pos = 3;
        else; key_pos = 1;
        end
        
        % redraw screen with with cursor in new position
        int_presentation(cfg,key_pos);
        
    % if right key, then select response
    elseif resp == 2
                
        % redraw screen with green response
        int_presentation(cfg,key_pos);
        
        % record response
        switch key_pos           
            case 1; log.task_raw{trl_at_enc,17} = 'guess';              
            case 2; log.task_raw{trl_at_enc,17} = 'unsure';
            case 3; log.task_raw{trl_at_enc,17} = 'certain';  
        end
        
        % add RT
        log.task_raw{trl_at_enc,18} = t3 - t1;
        log.task_raw{trl_at_enc,19} = t2 - t1;
        
        % wait 100ms
        WaitSecs(0.1);
        
        % exit function
        break
    end

end
end

function t1 = int_presentation(cfg,key_pos)

if key_pos == 1 % draw left response in color
    % draw ratings
    [~,~,x] = DrawFormattedText(cfg.screen.w1,'How confident are you about your choices?',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'How confident are you about your choices?',cfg.screen.pos.confiQ(1)-round(x(3)./2),cfg.screen.pos.confiQ(2)-round(x(4)./2),[0 0 0]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Guess ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Guess ]',cfg.screen.pos.confiR1(1)-round(x(3)./2),cfg.screen.pos.confiR1(2)-round(x(4)./2),[0 0 0]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Unsure ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Unsure ]',cfg.screen.pos.confiR2(1)-round(x(3)./2),cfg.screen.pos.confiR2(2)-round(x(4)./2),[200 200 200]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Certain ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Certain ]',cfg.screen.pos.confiR3(1)-round(x(3)./2),cfg.screen.pos.confiR3(2)-round(x(4)./2),[200 200 200]); % draw texture

    % present screen
    t1 = Screen('Flip',cfg.screen.w1); % flip
    
elseif key_pos == 2 % draw middle response in color
    % draw ratings
    [~,~,x] = DrawFormattedText(cfg.screen.w1,'How confident are you about your choices?',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'How confident are you about your choices?',cfg.screen.pos.confiQ(1)-round(x(3)./2),cfg.screen.pos.confiQ(2)-round(x(4)./2),[0 0 0]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Guess ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Guess ]',cfg.screen.pos.confiR1(1)-round(x(3)./2),cfg.screen.pos.confiR1(2)-round(x(4)./2),[200 200 200]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Unsure ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Unsure ]',cfg.screen.pos.confiR2(1)-round(x(3)./2),cfg.screen.pos.confiR2(2)-round(x(4)./2),[0 0 0]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Certain ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Certain ]',cfg.screen.pos.confiR3(1)-round(x(3)./2),cfg.screen.pos.confiR3(2)-round(x(4)./2),[200 200 200]); % draw texture

    % present screen
    t1 = Screen('Flip',cfg.screen.w1); % flip
    
elseif key_pos == 3 % draw right response in color
    % draw ratings
    [~,~,x] = DrawFormattedText(cfg.screen.w1,'How confident are you about your choices?',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'How confident are you about your choices?',cfg.screen.pos.confiQ(1)-round(x(3)./2),cfg.screen.pos.confiQ(2)-round(x(4)./2),[0 0 0]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Guess ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Guess ]',cfg.screen.pos.confiR1(1)-round(x(3)./2),cfg.screen.pos.confiR1(2)-round(x(4)./2),[200 200 200]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Unsure ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Unsure ]',cfg.screen.pos.confiR2(1)-round(x(3)./2),cfg.screen.pos.confiR2(2)-round(x(4)./2),[200 200 200]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Certain ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Certain ]',cfg.screen.pos.confiR3(1)-round(x(3)./2),cfg.screen.pos.confiR3(2)-round(x(4)./2),[0 0 0]); % draw texture

    % present screen
    t1 = Screen('Flip',cfg.screen.w1); % flip
end
end
