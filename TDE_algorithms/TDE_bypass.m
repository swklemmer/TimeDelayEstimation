function TDE_bypass(IData, QData)
%TDE_BYPASS
% Input: IData, QData, pagenum
% Size(IData) =
%   (Z dim, X dim, frame, page) = (PData.Size([1, 2]), 1, P.bmode_adq)
% Output: ImageData
% Size(ImageData) =
%   (Z dim, X dim) = PData.Size([1, 2])
% 
% PData.Size([1,2]) = [140, 43] @ pdelta = 0.3

% Declare variables common to all processes
persistent bmode_adq MovieData

% Run only at initialization
if isempty(bmode_adq)

    % Number of adquisitions
    bmode_adq = evalin('base', 'P.bmode_adq');

    % Pre-allocate movie data
    evalin('base', sprintf('MovieData = zeros(%d, %d, %d);', ...
        size(IData, 1), size(IData, 2), bmode_adq-1));
    MovieData = evalin('base', 'MovieData;');
end

for i=1:(bmode_adq-1)
    % Copy current b-mode in ImageBuffer
    MovieData(:, :, i) = squeeze(sqrt(IData(:, :, 1, i).^2 + ...
                                      QData(:, :, 1, i).^2));
end

% Save data to workspace
assignin('base', 'MovieData', MovieData);

% Save data to workspace
assignin('base', 'IData', IData);
assignin('base', 'QData', QData);

end
