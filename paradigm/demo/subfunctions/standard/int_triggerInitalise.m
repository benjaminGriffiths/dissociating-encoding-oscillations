function trig = int_triggerInitalise()

trig.PortAddress = hex2dec('BFF8'); %check this port address!
trig.ioObjTrig = io64;

% initialize the interface to the inpoutx64 system driver
trig.status = io64(trig.ioObjTrig);

%send 0 trigger (reset all pins)
io64(trig.ioObjTrig,trig.PortAddress,0); %trigger 0 (reset)

% define trigger values
trig.object  = 1;
trig.feature = 2;
trig.context = 4;
trig.imagery = 8;
trig.cue     = 16;
trig.distract = 32;

%% Send Test Pulses
trig_vals = {'object','feature','context','imagery','cue','distract'};
for i = 1 : numel(trig_vals)
    int_triggerSend(trig,trig_vals{i});
    WaitSecs(0.05);
end
