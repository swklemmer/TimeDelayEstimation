function Disp = TDE_Disp(fem_file, P, Parameters)
% Define Displacement structure array (simulation only).

% Load displacement info from .h5 file
[t_dim, x_dim, y_dim, z_dim, u_x, u_y, u_z] = load_u(fem_file);

Disp = struct('t_dim', t_dim,... % time dimention [s]
    'x_dim', x_dim / Parameters.lambda, ... % x dimention [wvls]
    'y_dim', y_dim / Parameters.lambda, ... % y dimention [wvls]
    'z_dim', P.startDepth + z_dim / Parameters.lambda, ... % z dim. [wvls]
    'u_x', u_x / Parameters.lambda, ...  % x displacement [wvls]
    'u_y', u_y / Parameters.lambda, ...  % y displacement [wvls]
    'u_z', u_z / Parameters.lambda);     % z displacement [wvls]

end
