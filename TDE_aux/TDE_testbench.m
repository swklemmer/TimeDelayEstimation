% INFO: NCC se pone ruidosa debido a la interpolación polinomial.
% Consideremos probar spline.

clear all;

% Experiment info
mu = 8500; % shear modulus [Pa]
alg_list = {'ncc', 'scc', 'lou'};
exp = 'test';
param = 0;

% Estimation parameters
est_param = repmat(struct( ...
    'ncc', struct( ...
        'axi_len', 9, ...       % NCC: Axial window length [wvls]
        'axi_hop', 1, ...       % NCC: Axial window hop [wvls]
        'lat_len', 1, ...       % NCC: Lateral window length [wvls]
        'lat_hop', 1, ...       % NCC: Lateral window hop [wvls]
        'fine_res', 0.1, ...    % NCC: Polynomial interp. res. [smpls]
        'med_sz', 7), ...       % NCC: Median filter size [smpls]
    'scc', struct( ...
        'axi_len', 15, ...      % SCC: Axial window length [wvls]
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
        'cum_sum', 15)), ...    % LOU: Moving average size [smpls]
    1, length(param));

if ~strcmp(exp, 'test')
    for alg = alg_list
        for i = 1:length(param)
            est_param(i).(alg{1}).(exp) = param(i);
        end
    end
end

% Specify constant parameters
P.startDepth = 10; % acquisition start depth [wavelengths]
P.endDepth = 80;   % acquisition end depth [wavelengths]
P.bmode_adq = 200; % b-mode adquisition number
P.simulate = 1;    % enable simulate mode

% Define Trans structure array.
[P, Trans] = TDE_Trans(P);

% Define system parameters.
Parameters = TDE_Parameters(P, Trans);

% Define PData structure array.
PData = TDE_PData(P, Trans);

% Define Displacement structure array (simulation only).
Disp = TDE_Disp(sprintf('./FemData/u_%d.h5', mu), P, Parameters);

for alg = alg_list
    for i = 1:length(param)
    
        % Change current parameters and raise flag
        current_param = est_param(i);
        param_flag = 1;
    
        for it = 1
            % Load IQData
            load(sprintf('IQData/IQData_u%d_i%d.mat', mu, it))
    
            % Estimate displacement and measure time
            tic(); TDE_estimate_u(IData{1}, QData{1}, alg{1}); time = toc()

            % Evaluate results
            [rmse, mae, sd] = TDE_eval_metrics(Disp, MovieData);
            
            % Save results
            save(sprintf('MovieData/%s/mu%d_%s_p%d', ...
                exp, mu, alg{1}, param(i)),...
                'MovieData', 'est_x', 'est_z', 'time', ...
                'rmse', 'mae', 'sd', 'param_table', 'P');
            
            % Show results
            hObject.Value = 0;
            TDE_show_movie(hObject, 0);
        end
    end
end
% TIMING (199 it.)
% Loupas        @ L9, N4, WX3   :  15,0s
% Built-in NCC  @ L10, f.05     : 186,9s
% Search NCC    @ L10, f.05, S5 : 305.9s