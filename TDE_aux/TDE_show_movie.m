function TDE_show_movie(hObject, ~)
%TDE_SHOW_MOVIE
    persistent fig

    % Retrieve estimated displacement and dimentions
    MovieData = evalin('base', 'MovieData');
    est_x = evalin('base', 'est_x');
    est_z = evalin('base', 'est_z');

    fig = figure();
    img = imagesc(est_x, est_z, squeeze(MovieData(: ,:, 1)), ...
        [min(MovieData, [], 'all'), max(MovieData, [], 'all')]);
    colorbar;

    % Display all frames within 3 seconds
    t = 1;
    while hObject.Value
        pause(3 / size(MovieData, 3))

        set(img, 'CData', squeeze(MovieData(:, :, t)));
        if t < size(MovieData, 3); t = t + 1;
            else; t = 1; end
    end

    close(fig)
end
