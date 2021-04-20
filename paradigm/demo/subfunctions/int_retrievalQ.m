function log = int_retrievalQ(cfg,log)

% define cursor position
key_pos = 1;

% draw screen with with cursor in first position
int_presentation(cfg,key_pos);

% wait for response
while true
	
    % check for response
    resp = int_getResponse(cfg);
        
    % if left key, then move cursor
    if resp == 1
        
        % update cursor position
        if key_pos ~= 5; key_pos = key_pos + 1;
        else; key_pos = 1;
        end
        
        % redraw screen with with cursor in new position
        int_presentation(cfg,key_pos);
        
        % wait momentarily        
        WaitSecs(0.1);
        
    % if right key, the record response
    elseif resp == 2
        
        % redraw screen with green response
        int_presentation(cfg,key_pos);

        % save retrieval score as key position       
        log.retScore = key_pos;
        
        % wait 250ms
        WaitSecs(0.25);
        
        % exit function
        break
    end

end
end

function int_presentation(cfg,key_pos)

[~,~,x] = DrawFormattedText(cfg.screen.w1,'When remembering, did you try to recall the target or reject the lures?',[],[],[255 255 255]);
DrawFormattedText(cfg.screen.w1,'When remembering, did you try to recall the target or reject the lures?',cfg.screen.pos.retmeQ(1)-round(x(3)./2),cfg.screen.pos.retmeQ(2),[0 0 0]); % draw texture

[~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Recall Target ]',[],[],[255 255 255]);
DrawFormattedText(cfg.screen.w1,'[ Recall Target ]',cfg.screen.pos.retmeR1(1)-round(x(3)./2),cfg.screen.pos.retmeR1(2),[0 0 0]); % draw texture

[~,~,x] = DrawFormattedText(cfg.screen.w1,'[ Reject Lures ]',[],[],[255 255 255]);
DrawFormattedText(cfg.screen.w1,'[ Reject Lures ]',cfg.screen.pos.retmeR2(1)-round(x(3)./2),cfg.screen.pos.retmeR2(2),[0 0 0]); % draw texture

for i = 1 : 5
    if i == key_pos
        [~,~,x] = DrawFormattedText(cfg.screen.w1,['[ ',num2str(i),' ]'],[],[],[255 255 255]);
        DrawFormattedText(cfg.screen.w1,['[ ',num2str(i),' ]'],cfg.screen.pos.retmeV(i,1)-round(x(3)./2),cfg.screen.pos.retmeV(i,2),[0 0 0]); % draw texture
    else
        [~,~,x] = DrawFormattedText(cfg.screen.w1,['[ ',num2str(i),' ]'],[],[],[255 255 255]);
        DrawFormattedText(cfg.screen.w1,['[ ',num2str(i),' ]'],cfg.screen.pos.retmeV(i,1)-round(x(3)./2),cfg.screen.pos.retmeV(i,2),[200 200 200]); % draw texture
    end
end

Screen('Flip',cfg.screen.w1); % flip   

end

