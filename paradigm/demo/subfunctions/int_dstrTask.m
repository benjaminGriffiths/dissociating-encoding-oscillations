function log = int_dstrTask(cfg,log,blk)

% define cursor position
key_pos = 1;

% generate random number
log.dstr_raw{end+1,1} = randi(99);
log.dstr_raw{end,5}   = blk; % add block number

% draw inital screen
oldTextSize=Screen('TextSize',cfg.screen.w1,16);
Screen('TextSize',cfg.screen.w1,oldTextSize+4);
[~,~,x] = DrawFormattedText(cfg.screen.w1, '?',0,0,[255 255 255]);
DrawFormattedText(cfg.screen.w1,'?',cfg.screen.pos.distrQ(1)-(x(3)/2),cfg.screen.pos.distrQ(2),[0 0 0]);

Screen('TextSize',cfg.screen.w1,oldTextSize);
[~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Odd ]',[],[],[255 255 255]);
DrawFormattedText(cfg.screen.w1,'[ Odd ]',cfg.screen.pos.distrR1(1)-(x(3)/2),cfg.screen.pos.distrR1(2),[200 200 200]); % draw texture

[~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Even ]',[],[],[255 255 255]);
DrawFormattedText(cfg.screen.w1,'[ Even ]',cfg.screen.pos.distrR2(1)-(x(3)/2),cfg.screen.pos.distrR2(2),[200 200 200]); % draw texture

% flip screen
Screen('Flip',cfg.screen.w1); % flip and get time

% wait for 750ms + +/-250ms jitter
WaitSecs(0.75 + ((rand(1)/2)-0.25));

% draw screen with integer
t1 = int_presentation(cfg,log.dstr_raw{end,1},key_pos);
t3 = [];

% wait for response
while true
	    
    [resp,t2] = int_getResponse(cfg.lj,cfg.lj.volt_thr);
    if isempty(t3); t3 = t2; end
    
    % if left key, then move cursor
    if resp == 1
        
        % update cursor position
        if key_pos == 1; key_pos = 2;
        else; key_pos = 1;
        end
        
        % redraw screen with with cursor in new position
        int_presentation(cfg,log.dstr_raw{end,1},key_pos);
        
        % wait momentarily        
        WaitSecs(0.25);
        
    % if right key, record response
    elseif resp == 2 
                        
        % if response is correct
        if int_isOdd(log.dstr_raw{end,1}) == int_isOdd(key_pos)

            % record response
            log.dstr_raw{end,2} = 'correct';
            log.dstr_raw{end,3} = t3-t1;
            log.dstr_raw{end,4} = t2-t1;

            % draw screen with integer
            int_presentation(cfg,log.dstr_raw{end,1},key_pos);
            
            % wait momentarily        
            WaitSecs(0.2);

            % load feedback img
            Screen('DrawTexture',cfg.screen.w1,cfg.images.tick); % draw texture

        else

            % record response
            log.dstr_raw{end,2} = 'incorrect';
            log.dstr_raw{end,3} = t3-t1;
            log.dstr_raw{end,4} = t2-t1;

            % draw screen with integer
            int_presentation(cfg,log.dstr_raw{end,1},key_pos);
            
            % wait momentarily        
            WaitSecs(0.2);

            % load feedback img
            Screen('DrawTexture',cfg.screen.w1,cfg.images.cross); % draw texture
        end
        
        % wait 100ms       
        Screen('Flip',cfg.screen.w1); % flip

        % wait 750ms
        WaitSecs(0.4);
        
        % exit function
        break
    end

end

end

% check if even
function b = int_isOdd(target_no)
b = mod(target_no,2) > 0;
end

function t1 = int_presentation(cfg,rand_int,key_pos)

% redraw question with number
oldTextSize=Screen('TextSize',cfg.screen.w1,16);
Screen('TextSize',cfg.screen.w1,oldTextSize+4);
[~,~,x] = DrawFormattedText(cfg.screen.w1, num2str(rand_int),0,0,[255 255 255]);
DrawFormattedText(cfg.screen.w1,num2str(rand_int),cfg.screen.pos.distrQ(1)-(x(3)/2),cfg.screen.pos.distrQ(2),[255 0 0]);

if key_pos == 1 % draw left response in red
    
    Screen('TextSize',cfg.screen.w1,oldTextSize);
    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Odd ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Odd ]',cfg.screen.pos.distrR1(1)-(x(3)/2),cfg.screen.pos.distrR1(2),[0 0 0]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Even ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Even ]',cfg.screen.pos.distrR2(1)-(x(3)/2),cfg.screen.pos.distrR2(2),[200 200 200]); % draw texture
    
else
    Screen('TextSize',cfg.screen.w1,oldTextSize);
    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Odd ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Odd ]',cfg.screen.pos.distrR1(1)-(x(3)/2),cfg.screen.pos.distrR1(2),[200 200 200]); % draw texture

    [~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Even ]',[],[],[255 255 255]);
    DrawFormattedText(cfg.screen.w1,'[ Even ]',cfg.screen.pos.distrR2(1)-(x(3)/2),cfg.screen.pos.distrR2(2),[0 0 0]); % draw texture
    
end

t1 = Screen('Flip',cfg.screen.w1); % flip   

end
