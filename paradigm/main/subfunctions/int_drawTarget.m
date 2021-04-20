function int_fixation(cfg)

% present fixation cross
dot_diam    = 15;
dot_pos     = cfg.screen.wc-(dot_diam/2);
Screen('DrawDots',cfg.screen.w1,dot_pos,dot_diam,[0 0 0]);% [,size] [,color] [,center] [,dot_type][, lenient]);;
Screen('Flip',cfg.screen.w1)
