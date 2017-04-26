% Function for benchmarking minibatch methods on the enz catalysis model.

% Artificial data is to be created beforehand.
% All options for the optimizer are to be passed over to this function.
% A log file is written by this function, with optimization history.

function status = evaluateMinibatchOptimization_EC(data, con0, ModelSpec, optimizer, OptimizerOptions)

    % Process input
    sigma2 = ModelSpec.sigma2;
    nTimepoints = ModelSpec.nTimepoints;
    nMeasure = ModelSpec.nMeasure;
    theta = ModelSpec.theta;
    
    %% Prepare optimization with PESTO
    % parameters
    parameters.name   = {'log(theta_1)', 'log(theta_2)', 'log(theta_3)', 'log(theta_4)'};
    parameters.min    = ModelSpec.lowerBound * ones(1, 4);
    parameters.max    = ModelSpec.upperBound * ones(1, 4);
    parameters.number = length(parameters.name);
    parameters.guess  = ModelSpec.par0;
    
    % objective function
    if strcmp(optimizer, 'fmincon')
        objectiveFunction = @(theta) logLikelihoodEC(theta, data, sigma2, con0, nTimepoints, 1:nMeasure);
    else
        objectiveFunction = @(theta, miniBatch) logLikelihoodEC(theta, data, sigma2, con0, nTimepoints, miniBatch);
    end
    
    % Pesto options
    optionsPesto           = PestoOptions();
    optionsPesto.obj_type  = 'log-posterior';
    optionsPesto.comp_type = 'sequential'; 
    optionsPesto.mode      = 'silent';
    optionsPesto.trace     = true;
    optionsPesto.plot_options.add_points.par = theta;
    optionsPesto.plot_options.add_points.logPost = objectiveFunction(theta, 1 : nMeasure);
    optionsPesto.localOptimizer = optimizer;
    optionsPesto.localOptimizerOptions = OptimizerOptions;
    
    try
        parameters = getMultiStarts(parameters, objectiveFunction, optionsPesto);
        save('parameters.mat','-struct','parameters');
        status = 1;
    catch 
        status = -1;
    end
end
