function [resp,t] = int_getResponse(L,volt_thr)

% loop till broken from
while true
    
    % cycle through buttons
    for button = 1 : 2
        
        % get voltage
        [~, r(button)] = L.ljudObj.eAIN(L.ljhandle, button-1, 31, 0, 0, 0, 0, 0);
        
        % check if voltage exceeds threshold
        if r(button) > volt_thr(button)
            resp = button;
            t = GetSecs;
            break
        end
    end
end
   