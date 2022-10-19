function [TX, TW, TPC] = TDE_Transmit(P, Parameters, Trans)
% Specify TX & TW structure arrays.

% #1: B-mode short pulse
TX(1) = struct( ...
    'waveform', 1, ...                      % selected waveform
    'Origin', [0.0, 0.0, 0.0], ...          % transmit focus origin
    'focus', 0, ...                         % focus depth [wvls]
    'Steer', [0.0, 0.0], ...                % theta, alpha
    'Apod', ones(1, Trans.numelements), ... % apodization
    'Delay', zeros(1, Trans.numelements));  % focus delays

TX(1).Delay = computeTXDelays(TX(1));       % compute delays

TW(1) = struct( ...             % specify waveform
    'type', 'parametric', ...   % waveform design method
    'Parameters', ...           %[freq., duty, #cycl, pol]
        [Trans.frequency, .67, 1, 1], ... 
    'sysExtendBL', 0);          % longer than 25 cycles

TPC(1) = struct( ...            % specify TX power controller profile
    'name', 'Imaging', ...
    'hv', 1.6, ...             % initial bipolar voltage
    'maxHighVoltage', 50, ...   % fixed max. voltage limit
    'highVoltageLimit', 40, ... % variable max. voltage limit
    'xmitDuration', 10);        % max. transmit duration [usec]

% #2: Push long pulse
N_push_elem = 64; % number of pushing elements (must not exceed max. I)
push_apod = [zeros(1, (Trans.numelements - N_push_elem) / 2), ...
            ones(1, N_push_elem), ...
            zeros(1, (Trans.numelements - N_push_elem) / 2)];

TX(2) = struct( ...
    'waveform', 2, ...                      % selected waveform
    'Origin', [0.0, 0.0, 0.0], ...          % transmit focus origin
    'focus', 0.012 / Parameters.lambda, ... % focus depth [wvls]
    'Steer', [0.0, 0.0], ...                % theta, alpha
    'Apod',  push_apod, ...                 % apodization
    'Delay', zeros(1, Trans.numelements));  % focus delays

TX(2).Delay = computeTXDelays(TX(2));       % compute delays

TW(2) = struct( ...             % specify waveform
    'type', 'parametric', ...   % waveform design method
    'Parameters', ...           %[freq., duty, #cycl, pol]
        [Trans.frequency, .5, 960, 1], ... % 960/2 cycles @ 7.6MHz = 64 us
    'sysExtendBL', 1);          % longer than 25 cycles

TPC(5) = struct( ...            % specify TX power controller profile
    'name', 'Push', ...
    'hv', P.hv, ...             % initial bipolar voltage
    'maxHighVoltage', 90, ...   % fixed max. voltage limit
    'highVoltageLimit', 90, ... % variable max. voltage limit
    'xmitDuration', 200);       % max. transmit duration [usec]

end
