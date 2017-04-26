
% Function in which common options for tuning parameters for minibatch
% optimization algorithms are set
%
% The algorithm must be passed to the function
% A struct is returned.

function OptimizerOptions = getOptimizerOptions(algorithm, miniBatchSize, ModelSpec)

    if strcmp(algorithm, 'fmincon')
        % fmincon options are set
        OptimizerOptions = optimset(...
                'algorithm', 'interior-point',...
                'display', 'off', ...
                'TolX', 1e-12, ...
                'TolFun', 1e-10, ...
                'TolGrad', 1e-6, ...
                'GradObj', 'on', ...
                'MaxIter', 2000, ...
                'PrecondBandWidth', inf);
            
    else
        % the generic options for delos are set
        OptimizerOptions(1) = struct(...
                'stochastic', true,...
                'miniBatchSize', miniBatchSize, ...
                'dataSetSize', ModelSpec.nMeasure, ...
                'barrier', 'log-barrier', ...
                'display', file, ...
                'outputID', [], ...
                'restriction', true, ...
                'reportInterval', 1, ...
                'method', 'rmsprop');
    end
    
    switch algorithm
        case 'rmsprop'
            
        case 'rmspropnesterov'
            
        case 'adam'
            OptimizerOptions(1).MaxIter = 400;
            OptimizerOptions(1).hyperparams = struct(...
                'rho1', 0.5, ...
                'rho2', 0.9, ...
                'delta', 1e-8, ...
                'eps0', 0.1, ...
                'epsTau', 1e-5, ...
                'tau', 250);
            
            OptimizerOptions(2) = optimizerOptions(1);
            OptimizerOptions(2).hyperparams.rho1 = 0.8;
            OptimizerOptions(2).hyperparams.rho2 = 0.9;
                        
            OptimizerOptions(3) = optimizerOptions(1);
            OptimizerOptions(3).hyperparams.rho1 = 0.9;
            OptimizerOptions(3).hyperparams.rho2 = 0.9;
            
            OptimizerOptions(4) = optimizerOptions(1);
            OptimizerOptions(4).hyperparams.rho1 = 0.9;
            OptimizerOptions(4).hyperparams.rho2 = 0.95;
 
            OptimizerOptions(5) = optimizerOptions(1);
            OptimizerOptions(5).hyperparams.rho1 = 0.5;
            OptimizerOptions(5).hyperparams.rho2 = 0.99;
            
            OptimizerOptions(6) = optimizerOptions(1);
            OptimizerOptions(6).hyperparams.rho1 = 0.8;
            OptimizerOptions(6).hyperparams.rho2 = 0.99;
            
            OptimizerOptions(7) = optimizerOptions(1);
            OptimizerOptions(7).hyperparams.rho1 = 0.9;
            OptimizerOptions(7).hyperparams.rho2 = 0.99;
            
            OptimizerOptions(8) = optimizerOptions(1);
            OptimizerOptions(8).hyperparams.rho1 = 0.9;
            OptimizerOptions(8).hyperparams.rho2 = 0.999;
            
            OptimizerOptions(9) = optimizerOptions(1);
            OptimizerOptions(9).hyperparams.rho1 = 0.5;
            OptimizerOptions(9).hyperparams.rho2 = 0.8;
            
        case 'adadelta'
            
    end
end