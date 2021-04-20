function epi_mem_demo

% TEMPORARY!
debug_mode = false;

%% Define Parameters
% define working directory
cfg.wdir = [pwd,'\'];
cd(cfg.wdir)
rmpath(genpath([cfg.wdir,'subfunctions']))
addpath([cfg.wdir,'subfunctions'])

% add response and trigger functions depending on debug
if debug_mode; addpath([cfg.wdir,'subfunctions\debug']);
else; addpath([cfg.wdir,'subfunctions\standard']);
end

% screen preferences
if debug_mode; Screen('Preference','SkipSyncTests', 1);
else; Screen('Preference','SkipSyncTests', 0);
end

% define screen parameters
cfg.screen.w_size = [];
cfg.screen.bckgrnd = [255 255 255];

% define variables
cfg.var.n_trl   = 2;  % number of trials
cfg.var.n_block = 1;    % number of blocks
cfg.var.t_block = cfg.var.n_trl./cfg.var.n_block; % number of trials per block

% define stimulus timings (in secs)
cfg.time.fixation = 0.5;
cfg.time.target   = 1.5;
cfg.time.imagery  = 3;
cfg.time.animateQ = 3;
cfg.time.cue      = 3;
cfg.time.distract = 60;

% define response parameters
cfg.resp.participant    = [37 39 27]; % left, right and down arrows
cfg.resp.experimenter   = 27; % escape key

% restrict response keys
RestrictKeysForKbCheck(cfg.resp.participant);

% define randomisation
cfg.rand.encoding   = {'animate_01.jpg','chequered_01.jpg','indoor_01.jpg';
                       'inanimate_01.jpg','polkadot_01.jpg','indoor_02.jpg'};

% define log file
log             = [];
log.task_hdr    = {'object_img','feature_img','context_img','trl_no_ret','block_no','pleasant_scr','pleasant_rt',...
                   'feat_mem','feat_rt','feat_key','scene_mem','scene_rt','scene_key','con_score','con_rt'};
log.task_raw    = cfg.rand.encoding;
log.dstr_hdr    = {};
log.dstr_raw    = {'value','response','rt','block'};
log.date        = int_getDate;
log.block_size  = cfg.var.t_block;

%% Prepare Screen
% prepare display
[cfg.screen.w1,cfg.screen.dim]          = Screen('OpenWindow',0,cfg.screen.bckgrnd,cfg.screen.w_size);
cfg.screen.w0                           = Screen('OpenOffscreenWindow',0,cfg.screen.bckgrnd,cfg.screen.w_size);
[cfg.screen.wc(1), cfg.screen.wc(2)]	= RectCenter(cfg.screen.dim);
cfg.screen.slack                        = Screen('getFlipInterval', cfg.screen.w1)/2;
cfg.screen.img_size                     = round(cfg.screen.dim(3:4) ./ 3);

Screen('FillRect',cfg.screen.w1,cfg.screen.bckgrnd,cfg.screen.dim);
Screen('Flip',cfg.screen.w1);

% screen preferences
Screen('TextSize',cfg.screen.w1,20);
Screen('TextFont',cfg.screen.w1,'Arial');
Screen('Preference','TextRenderer', 1);
Screen('Preference','TextAntiAliasing', 2);

%% Preload Images
cfg.images.fixation = Screen('MakeTexture',cfg.screen.w1,imread([cfg.wdir,'stimuli\fixation.jpg']));

tmp = imread([cfg.wdir,'stimuli\image_distractors\cross_v2.png']);
cfg.images.cross = Screen('MakeTexture',cfg.screen.w1,imresize(tmp,(cfg.screen.dim(3)/17)/size(tmp,1))); % convert image to texture

tmp = imread([cfg.wdir,'stimuli\image_distractors\tick_v2.png']);
cfg.images.tick = Screen('MakeTexture',cfg.screen.w1,imresize(tmp,(cfg.screen.dim(3)/17)/size(tmp,1))); % convert image to texture

cfg.images.nullstim =  Screen('MakeTexture',cfg.screen.w1,imread([cfg.wdir,'stimuli\null_stim.jpg']));

tmp = imread([cfg.wdir,'stimuli\arrow.jpg']);
cfg.images.arrowA  = Screen('MakeTexture',cfg.screen.w1,imrotate(imresize(tmp,(cfg.screen.dim(3)/17)/size(tmp,1)),90)); % convert image to texture
cfg.images.arrowB  = Screen('MakeTexture',cfg.screen.w1,imrotate(imresize(tmp,(cfg.screen.dim(3)/17)/size(tmp,1)),180)); % convert image to texture
cfg.images.arrowC  = Screen('MakeTexture',cfg.screen.w1,imrotate(imresize(tmp,(cfg.screen.dim(3)/17)/size(tmp,1)),270)); % convert image to texture

%% Initalise Triggers and Button
% run initialise function
cfg.trigger     = int_triggerInitalise();
cfg.lj          = int_buttonInitalise();

%% Screen Positioning
resp_img_size = round(cfg.screen.dim(3)/8);
resp_img_xSpace = round((cfg.screen.dim(3) - (resp_img_size.*3)) ./ 4);

cfg.screen.pos.pleasQ   = [1*round(cfg.screen.dim(3)/2) 1*round(cfg.screen.dim(4)/3)];
cfg.screen.pos.pleasR1  = [1*round(cfg.screen.dim(3)/3) 3*round(cfg.screen.dim(4)/5)];
cfg.screen.pos.pleasR2  = [2*round(cfg.screen.dim(3)/3) 3*round(cfg.screen.dim(4)/5)];

cfg.screen.pos.distrQ   = [1*round(cfg.screen.dim(3)/2) 1*round(cfg.screen.dim(4)/3)];
cfg.screen.pos.distrR1  = [1*round(cfg.screen.dim(3)/3) 3*round(cfg.screen.dim(4)/5)];
cfg.screen.pos.distrR2  = [2*round(cfg.screen.dim(3)/3) 3*round(cfg.screen.dim(4)/5)];

cfg.screen.pos.confiQ   = [1*round(cfg.screen.dim(3)/2) 1*round(cfg.screen.dim(4)/3)];
cfg.screen.pos.confiR1  = [1*round(cfg.screen.dim(3)/4) 3*round(cfg.screen.dim(4)/5)];
cfg.screen.pos.confiR2  = [2*round(cfg.screen.dim(3)/4) 3*round(cfg.screen.dim(4)/5)];
cfg.screen.pos.confiR3  = [3*round(cfg.screen.dim(3)/4) 3*round(cfg.screen.dim(4)/5)];

cfg.screen.pos.retmeQ   = [1*round(cfg.screen.dim(3)/2) 1*round(cfg.screen.dim(4)/3)];
cfg.screen.pos.retmeR1  = [1*round(cfg.screen.dim(3)/3) 6*round(cfg.screen.dim(4)/11)];
cfg.screen.pos.retmeR2  = [2*round(cfg.screen.dim(3)/3) 6*round(cfg.screen.dim(4)/11)];
cfg.screen.pos.retmeV   = round([5*round(cfg.screen.dim(3)/15) 7*round(cfg.screen.dim(4)/11);...
    6.25*round(cfg.screen.dim(3)/15) 7*round(cfg.screen.dim(4)/11);...
    7.5*round(cfg.screen.dim(3)/15) 7*round(cfg.screen.dim(4)/11);...
    8.75*round(cfg.screen.dim(3)/15) 7*round(cfg.screen.dim(4)/11);...
    10*round(cfg.screen.dim(3)/15) 7*round(cfg.screen.dim(4)/11)]);

cfg.screen.pos.ret_img(1,:) = [(resp_img_xSpace.*1)+(resp_img_size.*0), cfg.screen.wc(2) - (resp_img_size.*0.5),...
                              (resp_img_xSpace.*1)+(resp_img_size.*1), cfg.screen.wc(2) + (resp_img_size.*0.5)];
cfg.screen.pos.ret_img(2,:) = [(resp_img_xSpace.*2)+(resp_img_size.*1), cfg.screen.wc(2) - (resp_img_size.*0.5),...
                              (resp_img_xSpace.*2)+(resp_img_size.*2), cfg.screen.wc(2) + (resp_img_size.*0.5)];
cfg.screen.pos.ret_img(3,:) = [(resp_img_xSpace.*3)+(resp_img_size.*2), cfg.screen.wc(2) - (resp_img_size.*0.5),...
                              (resp_img_xSpace.*3)+(resp_img_size.*3), cfg.screen.wc(2) + (resp_img_size.*0.5)];

clear resp_img_size resp_img_xSpace resp_key_size resp_key_xSpace  
      
%% Run
% start timer
cfg.beginTime = GetSecs();

% start trial/blk counter
cfg.trialCount = 1;
cfg.blockCount = 1;

% present start screen
DrawFormattedText(cfg.screen.w1,'We''re ready to begin\n\nPress any key to begin','center','center');
Screen('Flip',cfg.screen.w1); % flip
KbWait();
 
% warn participant of next section
int_loadScreen(cfg,'encoding')

% cycle through each trial at encoding
for trl = 1 : log.block_size(end,1)

    % object
    int_fixation(cfg)
    int_target(cfg,'object')

    % feature
    int_fixation(cfg)
    int_target(cfg,'feature')

    % scene
    int_fixation(cfg)
    int_target(cfg,'context')

    % mental imagery
    int_fixation(cfg)
    int_target(cfg,'imagery')

    % animate/inanimate judgement
    log = int_pleasantQ(cfg,log);

    % update trial counter
    cfg.trialCount = cfg.trialCount + 1;
end

% warn participant of next section
int_loadScreen(cfg,'distractor')

% run distractor task
log = int_dstrTask_v2(cfg,log);

% warn participant of next section
int_loadScreen(cfg,'retrieval')

% reset trial counter to beginning of block and get block size
cfg.trialCount = cfg.trialCount - log.block_size(end,1);    

% get randomised retrieval order for this block    
cfg.rand.retrieval = {'02','chequered_01.jpg','polkadot_01.jpg','polkadot_02.jpg','indoor_01.jpg','outdoor_01.jpg','indoor_02.jpg';
                      '01','chequered_01.jpg','chequered_02.jpg','polkadot_01.jpg','indoor_01.jpg','outdoor_02.jpg','outdoor_01.jpg'};

% cycle through each trial at retrieval
for trl = 1 : log.block_size(end,1)

    % object
    int_fixation(cfg)
    int_target(cfg,'cue')

    % feature
    int_fixation(cfg)
    log = int_retResponse(cfg,log,'feature');

    % scene
    int_fixation(cfg)
    log = int_retResponse(cfg,log,'context');

    % confidence
    int_fixation(cfg)
    log = int_retConfidence(cfg,log);

    % update trial counter
    cfg.trialCount = cfg.trialCount + 1;
end   

% present feedback & exit
% get performance
A  = log.task_raw(cellfun(@isempty,log.task_raw(:,9)) == 0,[9 13]);
Ac = sum(all(ismember(A,'target'),2)) ./ size(A,1);

% present feedback
DrawFormattedText(cfg.screen.w1,sprintf('You are %3.0f%% complete\n\nYou recalled %3.0f%% of the triads in their entirety\n\n\n\n',100,Ac*100),'center','center',[0 0 0]);
Screen('Flip',cfg.screen.w1); % flip
WaitSecs(5);

% ask retrieval strategy
int_retrievalQ(cfg,log);

% enable all keys
RestrictKeysForKbCheck([])

% remove subfunction folder from path
rmpath(genpath([cfg.wdir,'subfunctions']))

% close screen
Screen('CloseAll')
