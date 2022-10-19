function TDE_move_scat

% Declare persistent variable to track time
persistent t t_max t_dim x_dim y_dim z_dim

% Run only at initialization
if isempty(t)
    t = 1;
    t_max = evalin('base', 'P.bmode_adq');

    % Get displacement dimentions
    t_dim = evalin('base', 'Disp.t_dim');
    x_dim = evalin('base', 'Disp.x_dim');
    y_dim = evalin('base', 'Disp.y_dim');
    z_dim = evalin('base', 'Disp.z_dim');
end

% Retrieve scatterer position and displacement info
Media = evalin('caller', 'Media');
u_x = squeeze(evalin('base', sprintf('Disp.u_x(%d, :, :, :)', t)));
u_y = squeeze(evalin('base', sprintf('Disp.u_y(%d, :, :, :)', t)));
u_z = squeeze(evalin('base', sprintf('Disp.u_z(%d, :, :, :)', t)));

% Interpolate values into new scatterer array
Media.MP(:, 1) = Media.OP(:, 1) + ...
        interp3(y_dim, x_dim, z_dim, u_x, abs(Media.OP(:, 2)), ...
        abs(Media.OP(:, 1)), Media.OP(:, 3), "linear", 0);

Media.MP(:, 2) = Media.OP(:, 2) + ...
        interp3(y_dim, x_dim, z_dim, u_y, abs(Media.OP(:, 2)), ...
        abs(Media.OP(:, 1)), Media.OP(:, 3), "linear", 0);

Media.MP(:, 3) = Media.OP(:, 3) + ...
        interp3(y_dim, x_dim, z_dim, u_z, abs(Media.OP(:, 2)), ...
        abs(Media.OP(:, 1)), Media.OP(:, 3), "linear", 0);

% Assign new position values to Media
assignin('base', 'Media', Media);

% Check if end was reached and update time
if t >= t_max
    t = 1;
elseif t < length(t_dim)
    t = t + 1;
end

end
