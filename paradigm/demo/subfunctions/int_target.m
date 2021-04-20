 function int_target(cfg,target_type)

x=GetSecs; % get function start time

% define index of target type
switch target_type
    case 'object'
        stim_folder = 'image_object';
        waitTime = cfg.time.target;
        stimulus = cfg.rand.encoding{cfg.trialCount,1};
        
    case 'feature'
        stim_folder = 'image_feature';
        waitTime = cfg.time.target;
        stimulus = cfg.rand.encoding{cfg.trialCount,2};
        
    case 'context'
        stim_folder = 'image_context';
        waitTime = cfg.time.target;
        stimulus = cfg.rand.encoding{cfg.trialCount,3};
        
    case 'cue'
        stim_folder = 'image_object';
        waitTime = cfg.time.cue;
        enc_trl  = str2double(cfg.rand.retrieval{cfg.trialCount,1});
        stimulus = cfg.rand.encoding{enc_trl,1};
        
    case 'imagery'        
        DrawFormattedText(cfg.screen.w1, 'create an image','center','center',[0 0 0]);
        Screen('Flip',cfg.screen.w1); % flip
        WaitSecs((x+cfg.time.imagery)-GetSecs);
        return
        
end

% prepare image
img     = imread([cfg.wdir,'stimuli\',stim_folder,'\',stimulus]); % read image
img     = imresize(img,mean(cfg.screen.img_size./[size(img,1) size(img,2)]));
im2txt  = Screen('MakeTexture',cfg.screen.w1,img); % convert image to texture

% draw texture
Screen('DrawTexture',cfg.screen.w1, im2txt);
Screen('Flip',cfg.screen.w1); % flip

% wait
WaitSecs((x+waitTime)-GetSecs);
