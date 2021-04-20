function lj = int_buttonInitalise()

%% Initalise Labjack
% Make the UD .NET assembly visible in MATLAB.
lj.ljasm = NET.addAssembly('LJUDDotNet');
lj.ljudObj = LabJack.LabJackUD.LJUD;

% Open the first found LabJack U3.
[lj.ljerror, lj.ljhandle] = lj.ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);

% Start by using the pin_configuration_reset IOType so that all pin
% assignments are in the factory default condition.
lj.ljudObj.ePutS(lj.ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

% define voltage threshold for button press
lj.volt_thr = 0.1;