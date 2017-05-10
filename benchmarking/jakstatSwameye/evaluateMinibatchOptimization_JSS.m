% Function for benchmarking minibatch methods on the jakstat Swameye model

% Artificial data is to be created beforehand.
% All options for the optimizer are to be passed over to this function.
% A log file is written by this function, with optimization history.

function [status, results] = evaluateMinibatchOptimization_JSS(data, con0, ModelSpec, optimizer, OptimizerOptions, resultsfolder)

    % Process input
    timepoints = ModelSpec.timepoints;
    nMeasure = ModelSpec.nMeasure;
    theta = ModelSpec.theta;
    multistarts = ModelSpec.multistarts;
    
    %% Prepare optimization with PESTO
    % parameters
    parameters.min = ModelSpec.lowerBounds;
    parameters.max = ModelSpec.upperBounds;
    parameters.number = length(parameters.min);
    parameters.name   = {'log_{10}(p1)','log_{10}(p2)','log_{10}(p3)','log_{10}(p4)',...
        'log_{10}(sp1)','log_{10}(sp2)','log_{10}(sp3)','log_{10}(sp4)','log_{10}(sp5)',...
        'log_{10}(offset_{tSTAT})','log_{10}(offset_{pSTAT})','log_{10}(scale_{tSTAT})','log_{10}(scale_{pSTAT})',...
        'log_{10}(\sigma_{pSTAT})','log_{10}(\sigma_{tSTAT})','log_{10}(\sigma_{pEpoR})'};
    parameters.guess  = ModelSpec.par0;
    
    % objective function
    if strcmp(optimizer, 'fmincon')
        objectiveFunction = @(theta) logLikelihoodJSS(theta, data, con0, timepoints, 1:nMeasure);
    else
        objectiveFunction = @(theta, miniBatch) logLikelihoodJSS(theta, data, con0, timepoints, miniBatch);
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
    jss_resultsfolder = [resultsfolder '/jakstatSwameye'];
    if ~exist(jss_resultsfolder,'dir')
        mkdir(jss_resultsfolder);
    end
        
    if ~strcmp(optimizer, 'fmincon')

        % Open a new file for this run to write the console output there
        iFile = 1;
        while iFile > 0
            jss_resultsfile = [jss_resultsfolder '/' OptimizerOptions.method '-Run-' num2str(iFile) '.txt'];
            if exist(jss_resultsfile,'file')
                iFile = iFile + 1;
            else
                outputID = fopen(jss_resultsfile, 'w');
                strFileNum = num2str(iFile);
                iFile = 0;
            end
        end

        % Write the optimization options to this file
        fprintf(outputID, '======================================\n');
        fprintf(outputID, ' Benchmarking Optimization with DELOS \n');
        fprintf(outputID, ' JAK2/STAT5 signaling Swameye example \n');
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
            save([jss_resultsfolder '/parameters-fmincon-Run.mat'], 'parameters');
        else
            save([jss_resultsfolder '/parameters-' OptimizerOptions.method '-Run-' strFileNum '.mat'], 'parameters');
            % plotMultiStartHistory(parameters);
        end
        results = struct(...
            'bestOptimum', -parameters.MS.logPost(1),...
            'meanOptimum', -mean(parameters.MS.logPost),...
            'medianOptimum', -median(parameters.MS.logPost),...
            'optima', -parameters.MS.logPost, ...
            'method', [], ...
            'runtime', sum(parameters.MS.t_cpu), ...
            'strrun', [], ...
            'run', [], ...
            'dataSetSize', [], ...
            'miniBatchSize', [], ...
            'MaxIter', [], ...
            'barrier', [], ...
            'restriction', [] ...
            );
        status = 1;
    catch errorMessage
        display(errorMessage.message);
        status = -1;
        results = [];
    end
    
    if ~strcmp(optimizer, 'fmincon')
        % close file handle
        fclose(outputID);
    end
end
