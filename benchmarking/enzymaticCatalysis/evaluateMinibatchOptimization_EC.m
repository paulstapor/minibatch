% Function for benchmarking minibatch methods on the enz catalysis model.

% Artificial data is to be created beforehand.
% All options for the optimizer are to be passed over to this function.
% A log file is written by this function, with optimization history.

function status = evaluateMinibatchOptimization_EC(data, con0, ModelSpec, optimizer, OptimizerOptions, resultsfolder)

    % Process input
    sigma2 = ModelSpec.sigma2;
    nTimepoints = ModelSpec.nTimepoints;
    nMeasure = ModelSpec.nMeasure;
    theta = ModelSpec.theta;
    multistarts = ModelSpec.multistarts;
    
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
    optionsPesto.n_starts  = multistarts;
    optionsPesto.obj_type  = 'log-posterior';
    optionsPesto.comp_type = 'sequential'; 
    optionsPesto.mode      = 'silent';
    optionsPesto.trace     = true;
    optionsPesto.plot_options.add_points.par = theta;
    if strcmp(optimizer, 'fmincon')
        optionsPesto.plot_options.add_points.logPost = objectiveFunction(theta);
    else
        optionsPesto.plot_options.add_points.logPost = objectiveFunction(theta, 1 : nMeasure);
    end
    optionsPesto.localOptimizer = optimizer;
    optionsPesto.localOptimizerOptions = OptimizerOptions;
    
    
    %% Prepare files for output
    
    % Create a new folder, if it doesn't exist yet
    ec_resultsfolder = [resultsfolder '/enzymaticCatalysis'];
    if ~exist(ec_resultsfolder,'dir')
        mkdir(ec_resultsfolder);
    end
        
    if ~strcmp(optimizer, 'fmincon')

        % Open a new file for this run to write the console output there
        iFile = 1;
        while iFile > 0
            ec_resultsfile = [ec_resultsfolder '/' OptimizerOptions.method '-Run-' num2str(iFile) '.txt'];
            if exist(ec_resultsfile,'file')
                iFile = iFile + 1;
            else
                outputID = fopen(ec_resultsfile, 'w');
                strFileNum = num2str(iFile);
                iFile = 0;
            end
        end

        % Write the optimization options to this file
        fprintf(outputID, '======================================\n');
        fprintf(outputID, ' Benchmarking Optimization with DELOS \n');
        fprintf(outputID, '      Enzymatic Catalysis Example     \n');
        fprintf(outputID, '======================================\n\n');
        fprintf(outputID, 'Date and time: %s \n\n', datetime);
        fprintf(outputID, 'Algorithm %s, Run nr. %s\n', OptimizerOptions.method, strFileNum);
        fprintf(outputID, 'Optimization options:\n');
        fprintf(outputID, '  stochastic: %i\n', OptimizerOptions.stochastic);
        fprintf(outputID, '  dataSetSize: %i\n', OptimizerOptions.dataSetSize);
        fprintf(outputID, '  miniBatchSize: %i\n', OptimizerOptions.miniBatchSize);
        fprintf(outputID, '  MaxIter: %i\n', OptimizerOptions.MaxIter);
        fprintf(outputID, '  barrier: %s\n', OptimizerOptions.barrier);
        fprintf(outputID, '  restriction: %i\n\n', OptimizerOptions.restriction);

        fprintf(outputID, 'Tuning parameters (hyperparameters):\n');
        tuningFields = fieldnames(OptimizerOptions.hyperparams);
        for iField = 1 : numel(tuningFields)
            fprintf(outputID, '  %s: %f\n', tuningFields{iField}, OptimizerOptions.hyperparams.(tuningFields{iField}));
        end

        fprintf(outputID, '\nConsole Output:\n\n');

        % Pass the file handle to the optimizer
        optionsPesto.localOptimizerOptions.outputID = outputID;
    end
    
    
    %% Run optimization
    % Use try-catch if something goes wrong to avoid the whole benchmark
    % script breaks down
    try
        parameters = getMultiStarts(parameters, objectiveFunction, optionsPesto);
        if strcmp(optimizer, 'fmincon')
            save([ec_resultsfolder '/parameters-fmincon-Run.mat'], 'parameters');
        else
            save([ec_resultsfolder '/parameters-' OptimizerOptions.method '-Run-' strFileNum '.mat'], 'parameters');
            % plotMultiStartHistory(parameters);
        end
        status = 1;
    catch errorMessage
        display(errorMessage.message);
        status = -1;
    end
    
    if ~strcmp(optimizer, 'fmincon')
        % close file handle
        fclose(outputID);
    end
end
