
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
                'display', 'iter', ...
                'TolX', 1e-12, ...
                'TolFun', 1e-10, ...
                'TolGrad', 1e-6, ...
                'GradObj', 'on', ...
                'MaxIter', 800, ...
                'PrecondBandWidth', inf);
            
    else
        % the generic options for delos are set
        OptimizerOptions(1) = struct(...
                'stochastic', true,...
                'miniBatchSize', miniBatchSize, ...
                'dataSetSize', ModelSpec.nMeasure, ...
                'barrier', 'log-barrier', ...
                'TolX', 1e-8, ...
                'display', 'file', ...
                'outputID', [], ...
                'restriction', true, ...
                'reportInterval', 1, ...
                'method', algorithm);
    end
    
    switch algorithm
        case 'rmsprop'
            OptimizerOptions(1).MaxIter = 600;
            OptimizerOptions(1).hyperparams = struct(...
                'rho', 0.5, ...
                'delta', 1e-8, ...
                'eps0', 0.1, ...
                'epsTau', 1e-4, ...
                'tau', 400);
            
            counter = 0;
            for rho = [0.5, 0.8, 0.9, 0.99]
                for epsTau = [1e-3, 1e-4, 1e-5]
                    for tau = [250, 333, 400, 500, 600]
                        counter = counter + 1;
                        OptimizerOptions(counter) = OptimizerOptions(1);
                        OptimizerOptions(counter).hyperparams.rho = rho;
                        OptimizerOptions(counter).hyperparams.epsTau = epsTau;
                        OptimizerOptions(counter).hyperparams.tau = tau;
                    end
                end
            end

            
        case 'rmspropnesterov'
            OptimizerOptions(1).MaxIter = 600;
            OptimizerOptions(1).hyperparams = struct(...
                'alphaStart', 0.5, ...
                'alphaEnd', 0.9, ...
                'tauAlpha', 200, ...
                'rho', 0.5, ...
                'delta', 1e-8, ...
                'eps0', 0.1, ...
                'epsTau', 1e-5, ...
                'tauEpsil', 400);
            
            counter = 0;
            for rho = [0.5, 0.9]
                for tauEpsil = [250, 450]
                    for tauAlpha = [250, 400, 600]
                        for alphaEnd = [0.6, 0.9]
                            for epsTau = [0.5e-4, 0.5e-6]
                                counter = counter + 1;
                                OptimizerOptions(counter) = OptimizerOptions(1);
                                OptimizerOptions(counter).hyperparams.rho = rho;
                                OptimizerOptions(counter).hyperparams.epsTau = epsTau;
                                OptimizerOptions(counter).hyperparams.tauEpsil = tauEpsil;
                                OptimizerOptions(counter).hyperparams.tauAlpha = tauAlpha;
                                OptimizerOptions(counter).hyperparams.alphaEnd = alphaEnd;
                            end
                        end
                    end
                end
            end
            
            
        case 'adam'
            OptimizerOptions(1).MaxIter = 600;
            OptimizerOptions(1).hyperparams = struct(...
                'rho1', 0.5, ...
                'rho2', 0.5, ...
                'delta', 1e-8, ...
                'eps0', 0.1, ...
                'epsTau', 1e-5, ...
                'tau', 333);
            
            counter = 0;
            for rho = [0.5, 0.8, 0.9, 0.99]
                for eps0 = [0.1, 0.025]
                    for tau = [300, 450]
                        counter = counter + 1;
                        OptimizerOptions(counter) = OptimizerOptions(1);
                        OptimizerOptions(counter).hyperparams.rho1 = rho;
                        OptimizerOptions(counter).hyperparams.rho2 = rho;
                        OptimizerOptions(counter).hyperparams.eps0 = eps0;
                        OptimizerOptions(counter).hyperparams.tau = tau;
                    end
                end
            end
            
            
        case 'adadelta'
            OptimizerOptions(1).MaxIter = 600;
            OptimizerOptions(1).hyperparams = struct(...
                'rho', 0.5, ...
                'eps0', 0.1, ...
                'delta0', 1e-3, ...
                'deltaTau', 1e-5, ...
                'tau', 200);
            
            counter = 0;
            
            for rho = [0.5, 0.8, 0.9, 0.99]
                for deltaTau = [1e-4, 1e-6, 1e-8]
                    for tau = [200, 333, 500]
                        counter = counter + 1;
                        OptimizerOptions(counter) = OptimizerOptions(1);
                        OptimizerOptions(counter).hyperparams.rho = rho;
                        OptimizerOptions(counter).hyperparams.deltaTau = deltaTau;
                        OptimizerOptions(counter).hyperparams.tau = tau;
                    end
                end
            end
            
    end
    
end