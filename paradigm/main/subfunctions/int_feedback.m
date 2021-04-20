function int_feedback(cfg,log)

% get performance
A  = log.task_raw(cellfun(@isempty,log.task_raw(:,9)) == 0,[9 13]);
Ac = sum(all(ismember(A,'target'),2)) ./ size(A,1);

% present feedback
DrawFormattedText(cfg.screen.w1,sprintf('You are %3.0f%% complete\n\nYou recalled %3.0f%% of the triads in their entirety\n\n\n\n',(cfg.trialCount./cfg.var.n_trl)*100,Ac*100),'center','center',[0 0 0]);
Screen('Flip',cfg.screen.w1); % flip

% check for response from experimenter
b=0;
while b == 0

    % break if button press
    b = KbCheck();

end
