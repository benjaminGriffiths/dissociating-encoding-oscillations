function log = int_dstrTask_v2(cfg,log)

% get function start time
x = GetSecs;

% send trigger
int_triggerSend(cfg.trigger,'distract')
log.dstr_evnt{cfg.blockCount+1}{1,1} = 'start';
log.dstr_evnt{cfg.blockCount+1}{1,2} = GetSecs-x;

% prepare images
cfg.dstr.cross.length = 25; % length of each of the four lines
cfg.dstr.cross.lines = [cfg.dstr.cross.length -cfg.dstr.cross.length 0 0; 0 0 cfg.dstr.cross.length -cfg.dstr.cross.length]; % define start and end points of the four lines
cfg.dstr.cross.width = 1.5; % thickness of cross lines

% define colours 
greyvalues = gray;
gradingIndex = floor(length(greyvalues)/3);
cfg.dstr.col.black = 0;
cfg.dstr.col.white = 255;
cfg.dstr.col.dgrey = greyvalues(gradingIndex,1).*255;
cfg.dstr.col.lgrey = greyvalues(length(greyvalues)-gradingIndex,1).*255;

% define delay windows
cfg.dstr.delay.ISI    = [16 17 18 19 20];

% turn screen black
Screen('FillRect',cfg.screen.w1,cfg.dstr.col.black);

% start counter
count = 0;

% while time elapsed is less than distractor duration
while x+cfg.time.distract > GetSecs

    % draw white fixation cross
    Screen('DrawLines',cfg.screen.w1,cfg.dstr.cross.lines,cfg.dstr.cross.width,cfg.dstr.col.lgrey,[cfg.screen.dim(3)/2 cfg.screen.dim(4)/2]);
    Screen('Flip',cfg.screen.w1);
    int_triggerSend(cfg.trigger,'distract')
    log.dstr_evnt{cfg.blockCount+1}{end+1,1}    = 'baseline';
    log.dstr_evnt{cfg.blockCount+1}{end,2}      = GetSecs-x;

    % wait delay
    WaitSecs(randsample(cfg.dstr.delay.ISI,1));            
    
    % determine grey fixation colour
    if rand(1) > 0.5; trl_col = cfg.dstr.col.white; et = 'lure';
    else; trl_col = cfg.dstr.col.dgrey; count = count + 1; et = 'target';
    end
    
    % draw grey fixation
    Screen('DrawLines',cfg.screen.w1,cfg.dstr.cross.lines,cfg.dstr.cross.width,trl_col,[cfg.screen.dim(3)/2 cfg.screen.dim(4)/2]);
    Screen('Flip',cfg.screen.w1);
    int_triggerSend(cfg.trigger,'distract')
    log.dstr_evnt{cfg.blockCount+1}{end+1,1}    = et;
    log.dstr_evnt{cfg.blockCount+1}{end,2}      = GetSecs-x;
    
    % wait delay
    WaitSecs(0.2);
end

% draw white fixation cross
Screen('DrawLines',cfg.screen.w1,cfg.dstr.cross.lines,cfg.dstr.cross.width,cfg.dstr.col.lgrey,[cfg.screen.dim(3)/2 cfg.screen.dim(4)/2]);
Screen('Flip',cfg.screen.w1);
log.dstr_evnt{cfg.blockCount+1}{end+1,1}    = 'baseline';
log.dstr_evnt{cfg.blockCount+1}{end,2}      = GetSecs-x;
WaitSecs(1);

% define key value
key_value = 0;

% draw screen
int_presentation(cfg,key_value);

% define int_resp variable
t1 = GetSecs;
t3 = [];

% wait for response
while true
	
    % check for response
    [resp,t2] = int_getResponse(cfg);
    if isempty(t3); t3 = t2; end
            
    % if left key, then move cursor
    if resp == 1
                
        % update cursor position
        if key_value ~= 10; key_value = key_value + 1;
        else; key_value = 0;
        end
        
        % redraw screen with with cursor in new position
        int_presentation(cfg,key_value);
        
    % if right key, then select response
    elseif resp == 2
                
        % redraw screen with green response
        int_presentation(cfg,key_value);
        
        % record responses
        log.dstr_task(cfg.blockCount+1,1) = cfg.blockCount; % block number
        log.dstr_task(cfg.blockCount+1,2) = count;          % number of d-gray fixes
        log.dstr_task(cfg.blockCount+1,3) = key_value;      % number of reported fixes
        log.dstr_task(cfg.blockCount+1,4) = t3-t1;          % time to first response
        log.dstr_task(cfg.blockCount+1,5) = t2-t1;          % time to confirmation
            
        % wait 100ms
        WaitSecs(0.1);
        
        % give feedback
        if log.dstr_task(cfg.blockCount+1,2) == log.dstr_task(cfg.blockCount+1,3)
            [~,~,x] = DrawFormattedText(cfg.screen.w1,'Correct!',[],[],[0 0 0]);
            DrawFormattedText(cfg.screen.w1,'Correct!',cfg.screen.pos.confiQ(1)-round(x(3)./2),cfg.screen.pos.confiQ(2)-round(x(4)./2),[0 255 0]); % draw texture
            Screen('Flip',cfg.screen.w1);
        else            
            [~,~,x] = DrawFormattedText(cfg.screen.w1,'Incorrect',[],[],[0 0 0]);
            DrawFormattedText(cfg.screen.w1,'Incorrect',cfg.screen.pos.confiQ(1)-round(x(3)./2),cfg.screen.pos.confiQ(2)-round(x(4)./2),[255 0 0]); % draw texture
            Screen('Flip',cfg.screen.w1);
        end

        % wait 100ms
        WaitSecs(1);
        
        % change background to white
        Screen('FillRect',cfg.screen.w1,cfg.dstr.col.white);
        Screen('Flip',cfg.screen.w1);
        
        % exit function
        break
    end

    % wait 150ms from button press to avoid rapid key press
    WaitSecs(0.15-(GetSecs-t2))
end
end

function t1 = int_presentation(cfg,key_value)

% draw ratings
[~,~,x] = DrawFormattedText(cfg.screen.w1,'How many dark grey crosses were presented?',[],[],[0 0 0]);
DrawFormattedText(cfg.screen.w1,'How many dark grey crosses were presented?\n\nLeft Button to increase value. Right button to confirm',cfg.screen.pos.confiQ(1)-round(x(3)./2),cfg.screen.pos.confiQ(2)-round(x(4)./2),[255 255 255]); % draw texture

[~,~,x] = DrawFormattedText(cfg.screen.w1,sprintf('[ %d ]',key_value),[],[],[0 0 0]);
DrawFormattedText(cfg.screen.w1,sprintf('[ %d ]',key_value),cfg.screen.pos.confiR2(1)-round(x(3)./2),cfg.screen.pos.confiR2(2)-round(x(4)./2),[255 255 255]); % draw texture

% present screen
t1 = Screen('Flip',cfg.screen.w1); % flip
    
end
