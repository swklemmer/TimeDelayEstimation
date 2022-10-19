function TDE_estimate_u_loupas(IData, QData)
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
persistent bmode_adq MovieData ...
           x_max z_max dz ens_len w_x w_z hop_x hop_z N_x N_z hann_win_F ...
    

% Run only at initialization
if isempty(bmode_adq)

    % Retrieve constant parameters
    bmode_adq = evalin('base', 'P.bmode_adq'); % Number of adquisitions

    % Get ROI dimensions
    x_max = evalin('base', 'PData.Size(2)'); % ROI size [wvls]
    z_max = evalin('base', 'PData.Size(1)'); % ROI size [wvls]
    dz = evalin('base', 'PData.PDelta(3)');  % z resolution [wvls]
    
    % Define window parameters
    ens_len = 4;  % N = Ensemble length

    w_x = 3;   % Lateral window length [smpls]
    hop_x = 1; % Lateral hop size
    N_x = floor((x_max - w_x) / hop_x); % Number of lateral windows

    axi_len = 9; % Axial window length [wvls]
    axi_hop = 1; % Window hop [wvls]
    w_z = ceil(axi_len / dz); % M = Axial window length [smpls]
    hop_z = max(floor(axi_hop / dz), 1); % Axial hop size [smpls]
    N_z = floor((z_max - w_z) / hop_z); % Number of axial windows

    % Create hann window
    hann_win_F = repmat(hann(w_z), 1, w_x);
    hann_win_f = repmat(hann(w_z-1), 1, w_x);
    %hann_win = ones(w_z, w_x);

    % Preallocate displacement
    evalin('base', sprintf('MovieData = zeros(%d, %d, %d);', ...
                            N_z, N_x, bmode_adq-ens_len-1))
    MovieData = evalin('base', 'MovieData');
end

% Estimate velocity
for t = 1:(bmode_adq-ens_len)
    % Calculate ensemble windows
    win_t_F = (1:ens_len-1) + (t - 1);
    win_t_f = (1:ens_len) + (t - 1);

    for x = 1:N_x
        % Calculate lateral window
        win_x = (1:w_x) + (x - 1) * hop_x;

        for z = 1:N_z
            % Calculate axial windows
            win_z_F = (1:w_z) + (z - 1) * hop_z;
            win_z_f = (1:w_z-1) + (z - 1) * hop_z;

            % Calculate frecuency estimates
            F_0 = atan(...
                sum(hann_win_F .* ...
                (QData(win_z_F, win_x, 1, win_t_F) .* ...
                IData(win_z_F, win_x, 1, win_t_F + 1) - ...
                IData(win_z_F, win_x, 1, win_t_F) .* ...
                QData(win_z_F, win_x, 1, win_t_F + 1)), 'all') / ...
                sum(hann_win_F .* ...
                (IData(win_z_F, win_x, 1, win_t_F) .* ...
                IData(win_z_F, win_x, 1, win_t_F + 1) + ...
                QData(win_z_F, win_x, 1, win_t_F) .* ...
                QData(win_z_F, win_x, 1, win_t_F + 1)), 'all')) / (2*pi);

            %if isnan(F_0); continue; end
        
            f_dopp = atan(...
                sum(hann_win_f .* ...
                (QData(win_z_f, win_x, 1, win_t_f) .* ...
                IData(win_z_f + 1, win_x, 1, win_t_f) - ...
                IData(win_z_f, win_x, 1, win_t_f) .* ...
                QData(win_z_f + 1, win_x, 1, win_t_f)), 'all') / ...
                sum(hann_win_f .* ...
                (IData(win_z_f, win_x, 1, win_t_f) .* ...
                IData(win_z_f + 1, win_x, 1, win_t_f) + ...
                QData(win_z_f, win_x, 1, win_t_f) .* ...
                QData(win_z_f + 1, win_x, 1, win_t_f)), 'all')) / (2*pi);
        
            % Calculate differential displacement [wvls]
            MovieData(z, x, t) =  F_0 / (1 + f_dopp) / 2;
        end
    end

    % Apply median filter
    MovieData(:, :, t) = medfilt2(MovieData(:, :, t), [5, 5], 'symmetric');
end

% Save accumulated displacement [wvls] to workspace 
assignin('base', 'MovieData', cumsum(MovieData, 3));

end
