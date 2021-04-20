function trig = int_triggerInitalise

trig.PortAddress = hex2dec('BFF8'); %check this port address!
trig.ioObjTrig = io64;

% initialize the interface to the inpoutx64 system driver
trig.status = io64(trig.ioObjTrig);

%send 0 trigger (reset all pins)
io64(trig.ioObjTrig,trig.PortAddress,0); %trigger 0 (reset)
