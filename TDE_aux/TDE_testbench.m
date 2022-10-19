clear all;

% Specify user defined parameters
P.startDepth = 10; % acquisition start depth [wavelengths]
P.endDepth = 80;   % acquisition end depth [wavelengths]
P.bmode_adq = 199; % b-mode adquisition number

% Define Trans structure array.
[P, Trans] = TDE_Trans(P);

% Define PData structure array.
PData = TDE_PData(P, Trans);

% Load IQData
load('IQData/IQData.mat')

% Estimate velocity
tic()
TDE_estimate_u(IData{1}, QData{1})
%TDE_estimate_u_ncc(IData{1}, QData{1})
%TDE_estimate_u_loupas(IData{1}, QData{1})
toc()

% Show results
hObject.Value = 1;
TDE_show_movie(hObject, 0);

% TIMING (199 it.)
% Loupas        @ L9, N4, WX3   :  15,0s
% Built-in NCC  @ L10, f.05     : 186,9s
% Search NCC    @ L10, f.05, S5 : 305.9s