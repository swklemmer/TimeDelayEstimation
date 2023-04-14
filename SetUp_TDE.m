% This script provides an environment to test different Time-Delay
% Estimation Algorithms.

clear
addpath('./lib/Auxiliar');
addpath('./lib/poly2D');

% Specify user defined parameters
P.startDepth = 10; % acquisition start depth [wavelengths]
P.endDepth = 80;   % acquisition end depth [wavelengths]
P.bmode_dly = 66;  % belay between b-mode images [usec] (15.2kHz)
P.bmode_adq = 100; % b-mode adquisition number
P.simulate = 1;    % enable simulate mode
P.hv = 30;         % transmition bipolar voltage

% Estimation parameters
param_flag = 1;
current_param = struct( ...
    'ncc', struct( ...
        'axi_len', 9, ...       % NCC: Axial window length [wvls]
        'axi_hop', 1, ...       % NCC: Axial window hop [wvls]
        'lat_len', 1, ...       % NCC: Lateral window length [wvls]
        'lat_hop', 1, ...       % NCC: Lateral window hop [wvls]
        'fine_res', 0.1, ...    % NCC: Polynomial interp. res. [smpls]
        'med_sz', 7), ...       % NCC: Median filter size [smpls]
    'scc', struct( ...
        'axi_len', 9, ...      % SCC: Axial window length [wvls]
        'axi_hop', 1, ...       % SCC: Axial window hop [wvls]
        'lat_len', 1, ...       % SCC: Lateral window length [wvls]
        'lat_hop', 1, ...       % SCC: Lateral window hop [wvls]
        'fine_res', 0.1, ...    % SCC: Polynomial interp. res. [smpls]
        'med_sz', 5, ...        % SCC: Median filter size [smpls]
        'search_z', 2, ...      % SCC: Axial disp. limit [wvls]
        'search_x', 2), ...     % SCC: Lateral disp. limit [wvls]
    'lou', struct( ...
        'axi_len', 9, ...       % LOU: Axial window length [wvls]
        'axi_hop', 1, ...       % LOU: Axial window hop [wvls]
        'lat_len', 1, ...       % LOU: Lateral window length [wvls]
        'lat_hop', 1, ...       % LOU: Lateral window hop [wvls]
        'med_sz', 7, ...        % LOU: Median filter size [smpls]
        'ens_len', 3, ...       % LOU: N = Ensemble length
        'cum_sum', 15));    % LOU: Moving average size [smpls]

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