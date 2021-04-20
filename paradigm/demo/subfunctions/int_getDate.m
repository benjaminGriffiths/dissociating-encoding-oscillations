function d = int_getDate

% this function returns the time and date in the format yy-mm-dd__hh-mm-ss

t = clock;
d = [sprintf('%02.0f',t(1)-2000),'-',sprintf('%02.0f',t(2)),'-',sprintf('%02.0f',t(3)),...
        '__',sprintf('%02.0f',t(4)),'-',sprintf('%02.0f',t(5)),'-',sprintf('%02.0f',t(6))];