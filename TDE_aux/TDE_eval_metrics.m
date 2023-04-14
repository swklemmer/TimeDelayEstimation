function [RMSE, MAE, SD] = TDE_eval_metrics(Disp, MovieData)
%TDE_EVAL_METRICS Compares real and estimated displacement and obtains
% following metrics: RMSE, MAE, SD

% Create list of estimation points
est_x = evalin('base', 'est_x');
est_z = evalin('base', 'est_z');
[est_x_grid, est_z_grid] = meshgrid(est_x, est_z);
est_pts = [est_x_grid(:), zeros(length(est_x_grid(:)), 1), est_z_grid(:)];

% Pre-allocate metrics
RMSE = zeros(size(MovieData, 3), 1);
MAE = zeros(size(MovieData, 3), 1);
SD = zeros(size(MovieData, 3), 1);

% Interpolate real displacement at estimation points
real_uz = zeros(size(MovieData));

for t = 1:size(MovieData, 3)
    u_z = squeeze(Disp.u_z(t, :, :, :));
    
    real_uz_t =  ...
        interp3(Disp.y_dim, Disp.x_dim, Disp.z_dim, u_z, ...
        abs(est_pts(:, 2)), abs(est_pts(:, 1)), est_pts(:, 3), ...
        "linear", 0);

    real_uz(:, :, t) = reshape(real_uz_t, size(MovieData, [1, 2]));

end

% Find gain that minimizes L2 error before comparisson
c = MovieData(:)' * real_uz(:) / (MovieData(:)' * MovieData(:))

for t = 1:size(MovieData, 3)

    % Evaluate estimator performance
    err = abs(c * MovieData(:, :, t) - real_uz(:, :, t));
    RMSE(t) = sqrt(mean(err.^2, 'all'));
    MAE(t) = mean(abs(err), 'all');
    SD(t) = std(err, 0, 'all');

end

end
