function int_triggerSend(trig,value)

io64(trig.ioObjTrig,trig.PortAddress,trig.(value)); %send trigger 16 (pin 5)
WaitSecs(0.01);
io64(trig.ioObjTrig,trig.PortAddress,0); %set back to zero 
