
% Function for setting model specifications for the small js model.

% A struct is returned which contains all important properties of the
% model for doing a multi-start optimization

function ModelSpec = writeModelSpec_JSS()

    multistarts = 15;
    lowerBounds = [-5, -3, -5, -3, -5, -5, -5,  -5, -9, -5, -5, -5, -5, -5, -5, -5]';
    upperBounds = [3, 8, 3, 8, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]';
    theta = ...
        [0.602655354873216
         5.99999864279214
        -0.954928836201376
        -0.0111599499755199
        -2.80956761765415
        -0.255716341749749
        -0.0765445797486006
        -0.407314040595421
        -5.46193996342345
        -0.731554047451398
        -0.654125364016903
        -0.108663908016977
         0.0100516805576264
        -1.42650215701577
        -1.34878872876133
        -1.16004338972210];
    
    ModelSpec = struct(...
        'nMeasure', 10, ...
        'multistarts', multistarts, ...
        'lowerBounds', lowerBounds, ...
        'upperBounds', upperBounds, ...
        'par0', bsxfun(@plus, lowerBounds, bsxfun(@times, upperBounds - lowerBounds, lhsdesign(multistarts, 16, 'smooth', 'off')')), ...
        'timepoints', [0;2;4;6;8;10;12;14;16;18;20;25;30;40;50;60], ...
        'theta', theta, ...
        'sigma', 10.^[-1.42650215701577; -1.34878872876133; -1.16004338972210] ...
        );

end