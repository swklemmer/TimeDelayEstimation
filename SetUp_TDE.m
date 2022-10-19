% This script provides an environment to test different Time-Delay
% Estimation Algorithms.

% TO DO: 
% Loupas tiene Aliasing!!! porque mi desplazamiento es mayor a lambda/2
% Debemos ver qué valores suele tomar el argumento del arctan
% En términos de velocidad, @ L=10, S5, N4
%   Built-in NCC: 0.02 s/it
%   NCC         : 1.4  s/it
%   Loupas      : 0.06 s/it

clear
addpath('./lib/Auxiliar');
addpath('./lib/poly2D');

% Specify user defined parameters
P.startDepth = 10; % acquisition start depth [wavelengths]
P.endDepth = 80;   % acquisition end depth [wavelengths]
P.bmode_dly = 66;  % belay between b-mode images [usec] (15.2kHz)
P.bmode_adq = 200; % b-mode adquisition number
P.simulate = 1;    % enable simulate mode
P.hv = 30;         % transmition bipolar voltage

% Define Trans structure array.
[P, Trans] = TDE_Trans(P);

% Define system parameters.
Parameters = TDE_Parameters(P, Trans);

% Define PData structure array.
PData = TDE_PData(P, Trans);

% Define Displacement structure array (simulation only).
Disp = TDE_Disp('./FemData/u_8500.h5', P, Parameters);

% Define Media object.
Media = TDE_Media(PData);

% Specify Receive Buffers.
[RcvBuffer, InterBuffer, ImageBuffer] = TDE_Buffers(P, Parameters);

% Specify Display Window.
DisplayWindow = TDE_DisplayWindow(PData);

% Gather Parameters, Buffers & DisplaWindows in Resource structure.
Resource = struct( ...
    'Parameters',    Parameters, ...
    'RcvBuffer',     RcvBuffer, ...
    'InterBuffer',   InterBuffer, ...
    'ImageBuffer',   ImageBuffer, ...
    'DisplayWindow', DisplayWindow, ...
    'HIFU', struct('voltageTrackP5', 0));

% Specify structure arrays for transmision.
[TX, TW, TPC] = TDE_Transmit(P, Parameters, Trans);

% Specify structure arrays for reception.
[Receive, TGC] = TDE_Receive(P, Trans);

% Specify structure arrays for reconstruction.
[Recon, ReconInfo] = TDE_Recon(P);

% Specify Process structure array.
Process = TDE_Process();

% Specify structure arrays for the Event Sequence.
[SeqControl, Event] = TDE_Event(P);

% Specify UI Control Elements
UI = TDE_GUI(P, Parameters, DisplayWindow, Recon);

% Save all the structures to a .mat file.
filename = 'TDE';
save(['MatFiles/', filename]);
VSX;