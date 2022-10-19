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

for t = 1:size(MovieData, 3)

    % Interpolate real displacement at pixel locations
    u_z = squeeze(Disp.u_z(t, :, :, :));
    
    real_uz =  ...
        interp3(Disp.y_dim, Disp.x_dim, Disp.z_dim, u_z, ...
        abs(est_pts(:, 2)), abs(est_pts(:, 1)), est_pts(:, 3), ...
        "linear", 0);

    real_uz = reshape(real_uz, size(MovieData, [1, 2]));

    % Normalize displacements (add epsilon to avoid division by zero)
    norm_est_u = MovieData(:, :, t) ./ (max(MovieData, [], 'all') + 1e-10);
    norm_real_u = real_uz ./ (max(real_uz, [], 'all') + 1e-10);

    % Evaluate estimator performance
    err = abs(norm_est_u - norm_real_u);
    RMSE(t) = sqrt(mean(err.^2, 'all'));
    MAE(t) = mean(abs(err), 'all');
    SD(t) = std(err, 0, 'all');

%     figure(1)
%     imagesc(est_x, est_z, norm_real_u, [-1, 1])
%     colorbar
% 
%     figure(2)
%     imagesc(est_x, est_z, norm_est_u, [-1, 1])
%     colorbar
% 
%     pause()
end

end
