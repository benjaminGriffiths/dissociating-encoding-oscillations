function [resp,t] = int_getResponse(cfg)

% restrict keys
RestrictKeysForKbCheck(cfg.resp.participant);

while true
    
    % wait to avoid repeated response
    WaitSecs(0.1);
    
    % check for response
    [~,~,key] = KbCheck();
    
    % if multiple response
    if numel(find(key)) == 1
        resp = find(find(key)==cfg.resp.participant);
        t = GetSecs;
        break
    end
        
end