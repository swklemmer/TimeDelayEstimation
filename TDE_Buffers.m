function [RcvBuffer, InterBuffer, ImageBuffer] = TDE_Buffers(P, Parameters)
% Specify Receive-, Inter- & ImageBuffers.

% A frame contains many adqusitions, stacked down vertically
% Number of samples = multiple of 128{4 samples/wvl x 2 decimation}
rows_per_adq = 128 * ceil(P.maxAcqLength * 8 / 128); 

% Receive Buffer in hardware
RcvBuffer(1) = struct( ...
    'datatype', 'int16', ...
    'rowsPerFrame', P.bmode_adq * rows_per_adq, ...% samples per frame
    'colsPerFrame', Parameters.numRcvChannels, ... % number of lines
    'numFrames', 1);                               % number of frames

% Receive Buffer in host computer (dimentions are defined by PData)
InterBuffer(1) = struct( ...
    'numFrames', 1, ...            % number of frames
    'pagesPerFrame', P.bmode_adq); % number of pages

% Image Buffers in host computer (dimentions are defined by PData)
ImageBuffer(1).numFrames = 1; % number of frames

end
