function TDE_estimate_u_ncc(IData, QData)
%TDE_ESTIMATE_U_NCC: Built-in normalized cross-correlation with polynomial 
% subsample 2D interpolation.
% Input: IData, QData
% Size(IData) =
%   (Z dim, X dim, frame, page) = (PData.Size([1, 2]), 1, P.bmode_adq)
% Output: MovieData
% Size(MovieData) = (Z est, X est, P.bmode_adq-1) 
% 
% PData.Size([1,2]) = [140, 43] @ pdelta = 0.3

% Declare static variables
persistent dz med_sz w_x w_z hop_x hop_z N_x N_z coarse_x coarse_z ...
    fine_dim fine_x fine_z bmode_adq MovieData

% Read parameter change flag
param_flag = evalin('base', 'param_flag');

% Run only at initialization
if param_flag

    % Lower flag
    assignin('base', 'param_flag', 0);

    % Retrieve constant parameters
    bmode_adq = evalin('base', 'P.bmode_adq');

    % Get ROI dimensions
    x_max = evalin('base', 'PData.Size(2)'); % ROI size [wvls]
    z_max = evalin('base', 'PData.Size(1)'); % ROI size [wvls]
    dx = evalin('base', 'PData.PDelta(1)');  % x resolution [wvls]
    dz = evalin('base', 'PData.PDelta(3)');  % z resolution [wvls]

    % Get estimation Parameters (may change due to grid resolution)
    est_param = evalin('base', 'current_param.ncc');
    axi_len = est_param.axi_len; % Axi. window length [wvls]
    lat_len = est_param.lat_len; % Lat. window length [wvls]
    axi_hop = est_param.axi_hop; % Axi. window hop [wvls]
    lat_hop = est_param.lat_hop; % Lat. window hop [wvls]
    fine_res = est_param.fine_res; % Fine resolution [samples]
    med_sz = est_param.med_sz;   % Median filter size [smpls]
    
    % Generate windows
    w_z = 1 + 2 * ceil(axi_len / dz / 2); % Axi. window length [samples]
    w_x = 1 + 2 * ceil(lat_len / dx / 2); % Lat. window length [samples]
    hop_z = max(floor(axi_hop / dz), 1); % Axi. hop size [samples]
    hop_x = max(floor(lat_hop / dx), 1); % Lat. hop size [samples]
    N_z = floor((z_max - w_z) / hop_z);  % Number of windows
    N_x = floor((x_max - w_x) / hop_x);  % Number of windows

    % Save parameters to text file
    param = {'Axi. Win. Size'; 'Axi. Win. Hop'; ...
            'Lat. Win. Size'; 'Lat. Win. Hop'; ...
            'Subsample Res.'; 'Median Filter Size'};
    value = [w_z * dz; hop_z * dz; w_x * dx; hop_x * dx; fine_res; med_sz];
    units = {'wvls'; 'wvls'; 'wvls'; 'wvls'; 'smpls'; 'smpls'};
    param_table = table(param, value, units);
    evalin('base', 'param_table = table();');
    assignin('base', 'param_table', param_table);
    
    % Create coarse and fine grids
    [coarse_x, coarse_z] = meshgrid(-2:2, -2:2);
    fine_dim = (-2:fine_res:2);
    [fine_x, fine_z] = meshgrid(fine_dim, fine_dim);

    % Generate 2D Hanning window
    hann_win = hanning(w_z) * hanning(w_x)';

    % Generate estimation dimentions [wvls]
    evalin('base', ...
        sprintf(...
        ['est_x = PData.Origin(1) + (%d/2 + (0:(%d-1)) * %d)', ...
        '* PData.PDelta(1);'], w_x, N_x, hop_x))

    evalin('base', ...
        sprintf(...
        ['est_z = PData.Origin(3) + (%d/2 + (0:(%d-1)) * %d)',...
        '* PData.PDelta(3);'], w_z, N_z, hop_z))

    % Preallocate displacement
    evalin('base', sprintf('MovieData = zeros(%d, %d, %d);', ...
                            N_z, N_x, bmode_adq-1))
    MovieData = evalin('base', 'MovieData');
end

% Get pre-deformation magnitude from Interbuffer's 1st page
pre_sono = squeeze(sqrt(IData(:, :, 1, 1).^2 + QData(:, :, 1, 1).^2));

for t = 2:bmode_adq

    % Get post-deformation magnitude
    post_sono = squeeze(sqrt(IData(:, :, 1, t).^2 + QData(:, :, 1, t).^2));

    % Estimate displacement
    for x = 1:N_x
        for z = 1:N_z
    
            % Calculate correlation between windows
            win_z = (1:w_z) + (z - 1) * hop_z;
            win_x = (1:w_x) + (x - 1) * hop_x;

            % Calculate correlation (size = 2 w_z - 1 , 2 w_x - 1)
            win_corr = normxcorr2(hann_win .* pre_sono(win_z, win_x), ...
                                  hann_win .* post_sono(win_z, win_x));

            % Find maximum with coarse precission
            [~, max_corr] = max(win_corr, [], 'all');
            [max_z, max_x] = ind2sub(size(win_corr), max_corr);

            % Establish coarse displacement limit (3, 2W - 3)
            max_z = min(max(max_z, 3), 2 * w_z - 3);
            max_x = min(max(max_x, 3), 2 * w_x - 3);
    
            % Fit correlation to polynomial around coarse maximum
            xcorr_p = polyFit2D(win_corr((-2:2) + max_z, (-2:2) + max_x), ...
                          coarse_z, coarse_x, 4, 4);

            % Evaluate polynomial with fine precission
            fine_xcorr = polyVal2D(xcorr_p, fine_z, fine_x, 4, 4);

            % Find maximum in fine grid
            [~, max_poly] = max(fine_xcorr, [], 'all');
            [~, max_dz] = ind2sub(size(fine_xcorr), max_poly);
  
            % Calculate displacement
            MovieData(z, x, t-1) = (max_z - w_z + fine_dim(max_dz)) * dz;
        end
    end
    % Apply median filter
    MovieData(:, :, t-1) = medfilt2(MovieData(:, :, t-1), ...
                        [med_sz, med_sz], 'symmetric');
end

% Save displacement to workspace
assignin('base', 'MovieData', MovieData);
end
