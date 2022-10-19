function TDE_estimate_u(IData, QData)
%TDE_ESTIMATE_U
% Input: IData, QData, pagenum
% Size(IData) =
%   (Z dim, X dim, frame, page) = (PData.Size([1, 2]), 1, P.bmode_adq)
% Output: ImageData
% Size(ImageData) =
%   (Z dim, X dim) = PData.Size([1, 2])
% 
% PData.Size([1,2]) = [140, 43] @ pdelta = 0.3

% Declare static variables
persistent x_max z_max dx dz w_x w_z hop_x hop_z N_x N_z ...
    search_dim coarse_x coarse_z fine_dim fine_x fine_z search_x search_z ...
    bmode_adq MovieData

% Run only at initialization
if isempty(bmode_adq)

    % Number of adquisitions
    bmode_adq = evalin('base', 'P.bmode_adq');

    % Get ROI dimensions
    x_max = evalin('base', 'PData.Size(2)'); % ROI size [wvls]
    z_max = evalin('base', 'PData.Size(1)'); % ROI size [wvls]
    dx = evalin('base', 'PData.PDelta(1)');  % x resolution [wvls]
    dz = evalin('base', 'PData.PDelta(3)');  % z resolution [wvls]
    
    % Generate windows
    win_len = 10; % window length [wvls]
    win_hop = 1; % window hop [wvls]
    w_x = 1 + 2 * ceil(win_len / dx / 2); % Uneven window length [samples]
    w_z = 1 + 2 * ceil(win_len / dz / 2); % Uneven window length [samples]
    hop_x = max(floor(win_hop / dx), 1); % Window hop size [samples]
    hop_z = max(floor(win_hop / dz), 1); % Window hop size [samples]
    N_x = floor((x_max - w_x) / hop_x); % Number of windows
    N_z = floor((z_max - w_z) / hop_z); % Number of windows
    
    % Create coarse and fine grids
    [coarse_x, coarse_z] = meshgrid(-2:2, -2:2);
    fine_dim = (-2:0.05:2);
    [fine_x, fine_z] = meshgrid(fine_dim, fine_dim);

    % Define search space (maximum allowed displacement)
    search_x = 5;
    search_z = 5;
    search_dim = -search_z:search_z;

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
            win_x = (1:w_x) + (x - 1) * hop_x;
            win_z = (1:w_z) + (z - 1) * hop_z;

            % Calculate correlation only within search space
            win_corr = ncc2d(pre_sono(win_z, win_x), ...
                             post_sono(win_z, win_x), ...
                             [search_z, search_x]);
    
            % Find maximum with coarse precission
            [~, max_corr] = max(win_corr, [], 'all');
            [max_z, max_x] = ind2sub(size(win_corr), max_corr);
    
            % Establish coarse displacement limit (3, 2W - 3)
            max_z = min(max(max_z, 3), 2 * search_z - 3);
            max_x = min(max(max_x, 3), 2 * search_x - 3);
    
            % Fit correlation to polynomial around coarse maximum
            xcorr_p = polyFit2D(win_corr((-2:2) + max_z, (-2:2) + max_x), ...
                          coarse_z, coarse_x, 4, 4);

            % Evaluate polynomial with fine precission
            fine_xcorr = polyVal2D(xcorr_p, fine_z, fine_x, 4, 4);

            % Find maximum in fine grid
            [~, max_poly] = max(fine_xcorr, [], 'all');
            [~, max_dz] = ind2sub(size(fine_xcorr), max_poly);
    
            % Calculate displacement
            MovieData(z, x, t-1) = ...
                - (search_dim(max_z) + fine_dim(max_dz)) * dz;
        end
    end
end

% Save displacement to workspace
assignin('base', 'MovieData', MovieData);
end
