function [P, Trans] = TDE_Trans(P)
% Define Trans structure array.

Trans = struct( ...
    'name',             'L11-5v', ...      % known transducer name
    'units',            'wavelengths', ... % distance units
    'maxHighVoltage',   90);               % pulser voltage limit

Trans = computeTrans(Trans);

% Calculate maximum adquisition length [wvls]
P.maxAcqLength = ... % longest distance between element and scatterer
    ceil(sqrt(P.endDepth^2 + ((Trans.numelements - 1) * Trans.spacing)^2));

% Calculate max frame rates
T_img = 2 * (P.maxAcqLength + 1) / Trans.frequency;
T_tot = 2 * ((P.maxAcqLength + 1) * (P.bmode_adq + 1) + 480) ...
    / Trans.frequency;
fprintf("Max. img rate = %5.2f kHz\n", 1e3/T_img);
fprintf("Max. SWE rate = %5.2f kHz\n", 1e3/T_tot);
end
