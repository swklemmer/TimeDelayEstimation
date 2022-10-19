function TDE_show_movie(hObject, ~)
%TDE_SHOW_MOVIE
    persistent fig

    MovieData = evalin('base', 'MovieData');

    fig = figure();
    img = imagesc(squeeze(MovieData(: ,:, 1)), ...
        [min(MovieData, [], 'all'), max(MovieData, [], 'all')]);
    colorbar;

    % Display all frames within 3 seconds
    t = 1;
    while hObject.Value
        pause(3 / size(MovieData, 3))
        %waitforbuttonpress()
        set(img, 'CData', squeeze(MovieData(:, :, t)));
        if t < size(MovieData, 3); t = t + 1;
            else; t = 1; end
    end

    close(fig)
end