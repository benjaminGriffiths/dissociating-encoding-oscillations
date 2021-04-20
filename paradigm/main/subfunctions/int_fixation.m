function int_fixation(cfg)

x=GetSecs; % get function start time
 
img     = imread([cfg.wdir,'stimuli\fixation.jpg']); % read image
im2txt  = Screen('MakeTexture',cfg.screen.w1,img); % convert image to texture
Screen('DrawTexture',cfg.screen.w1, im2txt); % draw texture
Screen('Flip',cfg.screen.w1); % flip

% get jitter
jitter = (rand(1).*0.2)-0.1;

% wait fixation duration minus time taken to execute function
WaitSecs((x+cfg.time.fixation+jitter)-GetSecs);
