function int_animateQ(cfg,log,blk,trl)
     
x=GetSecs; % get function start time

% define screen positions
xleft   = round(0.5.*cfg.screen.wc(1));
xright  = round(1.5.*cfg.screen.wc(1));
xcent   = round(cfg.screen.wc(1));
ytop    = round(0.5.*cfg.screen.wc(2));
ymid    = round(cfg.screen.wc(2));
ybot    = round(1.5.*cfg.screen.wc(2));

% draw question
DrawFormattedText(cfg.screen.w1, 'Was the object animate or inanimate?','center','center',[],[],[],[],[],[],[xcent-400 ytop-200 xcent+400 ytop+200]);
DrawFormattedText(cfg.screen.w1, 'Animate','center','center',[],[],[],[],[],[],[xleft-200 ymid-200 xleft+200 ymid+200]);
DrawFormattedText(cfg.screen.w1, 'Inanimate','center','center',[],[],[],[],[],[],[xright-200 ymid-200 xright+200 ymid+200]);
DrawFormattedText(cfg.screen.w1, '[1]','center','center',[],[],[],[],[],[],[xleft-400 ybot-200 xleft+400 ybot+200]);
DrawFormattedText(cfg.screen.w1, '[2]','center','center',[],[],[],[],[],[],[xright-400 ybot-200 xright+400 ybot+200]);
t1 = Screen('Flip',cfg.screen.w1); % flip and get time

% wait for response
while (GetSecs - x) < cfg.time.animateQ
	[b,t2,key] = KbCheck();

    if b == 1
        
        % log responses
        LOG.recognition.confidence.key(trial) = find(key,1);
        LOG.recognition.confidence.rt(trial)  = t2 - t1;
        
        % exit function
        break
    end

end

