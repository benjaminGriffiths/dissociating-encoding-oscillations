function [resp,t] = int_getResponse(cfg)

% loop till broken from
while true
    
    % cycle through buttons
    for button = 1 : 2
        
        % get current state      
        [~,cs]  = cfg.lj.ljudObj.eDI(cfg.lj.ljhandle, button+15, 1); % check digital bit 16 (CIO0) and digital bit 17 (CIO1)
        
        % get time
        t       = GetSecs();
        
        % check if voltage exceeds threshold
        if cs < 1
            resp = button;
            WaitSecs(0.25); % wait to avoid press overlap
            return
        end
    end
end
   