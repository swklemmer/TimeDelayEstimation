% INFO: NCC se pone ruidosa debido a la interpolación polinomial.
% Consideremos probar spline.

clear all;

% Experiment info
alg = 'scc';
exp = 'lat_len';
param = [1]; % window lengths [wvls]

% Estimation parameters
est_param = repmat(struct( ...
    'axi_len', 15, ...      % ALL: Axial window length [wvls]
    'axi_hop', 1, ...       % ALL: Axial window hop [wvls]
    'lat_len', 1, ...       % ALL: Lateral window length [wvls]
    'lat_hop', 1, ...       % ALL: Lateral window hop [wvls]
    'fine_res', 0.05, ...   % CC: Polynomial interp. res. [smpls]
    'search_z', 3, ...      % SCC: Axial disp. limit [wvls]
    'search_x', 3, ...      % SCC: Lateral disp. limit [wvls]
    'ens_len', 4, ...       % LOU: N = Ensemble length
    'med_sz', 5), ...       % LOU: Median filter size [smpls]
    1, length(param));

for i = 1:length(param)
    est_param(i).lat_len = param(i);
end

% Specify constant parameters
P.startDepth = 10; % acquisition start depth [wavelengths]
P.endDepth = 80;   % acquisition end depth [wavelengths]
P.bmode_adq = 199; % b-mode adquisition number
P.simulate = 1;    % enable simulate mode

% Define Trans structure array.
[P, Trans] = TDE_Trans(P);

% Define system parameters.
Parameters = TDE_Parameters(P, Trans);

% Define PData structure array.
PData = TDE_PData(P, Trans);

% Define Displacement structure array (simulation only).
mu = 8500; % shear modulus [Pa]
Disp = TDE_Disp(sprintf('./FemData/u_%d.h5', mu), P, Parameters);

for i = 1:length(param)

    % Change current parameters and raise flag
    current_param = est_param(i);
    param_flag = 1;

    for it = 1
        % Load IQData
        load(sprintf('IQData/IQData_u%d_i%d.mat', mu, it))
        IData{1}(:, :, 1, 2) = IData{1}(:, :, 1, 1);
        QData{1}(:, :, 1, 2) = QData{1}(:, :, 1, 1);

        % Estimate displacement and measure time
        tic(); TDE_estimate_u(IData{1}, QData{1}, alg); time = toc()
        
        % Evaluate results
        [rmse, mae, sd] = TDE_eval_metrics(Disp, MovieData);
        
        % Save results
        save(sprintf('MovieData/%s/mu%d_%s_p%d', exp, mu, alg, param(i)),...
            'MovieData', 'est_x', 'est_z', 'time', 'rmse', 'mae', 'sd',...
            'param_table', 'P');
        
        % Show results
        hObject.Value = 0;
        TDE_show_movie(hObject, 0);
    end
end

% TIMING (199 it.)
% Loupas        @ L9, N4, WX3   :  15,0s
% Built-in NCC  @ L10, f.05     : 186,9s
% Search NCC    @ L10, f.05, S5 : 305.9s