
% Function for running the benchmarking test suite for minibatch methods.
%
% A number of examples will be run. They include
%   * enzymatic catalysis model
%       (artificial data, 4 parameters, AMICI model)
%   * mRNA transfection model
%       (artificial data, 5 parameters, analytic solve)
%   * JAK2/STAT5 model based on Swameye
%       (artificial data, 17 parameters, AMICI model)
%   * JAK2/STAT5 model based on Bachmann, Adlung
%       (real data, 186 parameters, MEMOIR model)
%   * ErbBsignaling model from Chen et al.
%       (artificial data, 219 parameters, AMICI model)
%
% Optimization is carried out in minibatch e.g. stocahstic mode.
%
% Each optimization is run with different algorithms and different tuning
% parameters.
%
% Results are written to .mat files (optimization results) and to .txt
% files (console output).

function runMinibatchBenchmarkSuite()
    %% Specify general things
    
    % Write and set folders for the output
    [exdir,~,~] = fileparts(which('runMinibatchBenchmarkSuite.m'));
    folderdate = date;
    iFolder = 1;
    while iFolder > 0
        resultsfolder = [exdir '/results/' folderdate '_Run-' num2str(iFolder)];
        if exist(resultsfolder,'dir')
            iFolder = iFolder + 1;
        else
            iFolder = 0;
            mkdir(resultsfolder);
        end
    end
    
    % Setting up results struct
    globalOutputID = fopen([resultsfolder '/optimizationStatus.txt'], 'w');
        results = struct(...
            'bestOptimum', [], ...
            'meanOptimum', [], ...
            'medianOptimum', [], ...
            'optima', [], ...
            'method', [], ...
            'runtime', [], ...
            'strrun', [], ...
            'run', [], ...
            'dataSetSize', [], ...
            'miniBatchSize', [], ...
            'MaxIter', [], ...
            'barrier', [], ...
            'restriction', [] ...
            );
    
    % Specify the algorithms which are to be benchmarked
    algorithms = {'rmsprop', 'rmspropnesterov', 'adam', 'adadelta'};
        
    
    
%     %% Enzymatic catalysis example
%     
%     fprintf(1, 'Enzymatic catalysis model...\n');
%     
%     % Add the path for the enzymatic example
%     addpath('./enzymaticCatalysis');
%     fprintf(globalOutputID, 'Benchmarking for the enzymatic catalysis example:\n');
%     
%     % Set model specifications
%     ModelSpec = writeModelSpec_EC();
%     
%     % Write Data and initial parameters for enzymatic catalysis
%     fprintf(1, '   ...writing data\n');
%     writeArtificialData_EC(ModelSpec);
%     
%     % Get data and initial concentrations, prepare optimization
%     fprintf(1, '   ...loading data\n');
%     data = getArtificialData_EC();
%     con0 = getConditions_EC();
%     
%     % Do one test run with fmincon to have a solid benchmark
%     fprintf(1, '   ...running fmincon\n');
%     OptimizerOptions = getOptimizerOptions('fmincon', [], ModelSpec);
%     [status, results(1)] = evaluateMinibatchOptimization_EC(data, con0, ModelSpec, 'fmincon', OptimizerOptions, resultsfolder);
%     
%     % Write results to an output file
%     fprintf(globalOutputID, '\n  The fmincon benchmarking run ended with status %3i', status);
%     
%     % Do runs for different algorithms and tuning parameters
%     fprintf(1, '   ...running DELOS...\n');
%     miniBatchSize = 2;
%     iRun = 1;
%     
%     for algorithm = algorithms
%         
%         fprintf(1, '      ...with %s...\n', algorithm{1});
%         
%         % Get the tuning parameters for the current optimization algorithm
%         OptimizerOptions = getOptimizerOptions(algorithm{1}, miniBatchSize, ModelSpec);
%         
%         % Run through all optimizer options for the current algorithm
%         for j = 1 : length(OptimizerOptions)
%             iRun = iRun + 1;
%             [status, results(iRun)] = evaluateMinibatchOptimization_EC(data, con0, ModelSpec, 'delos', OptimizerOptions(j), resultsfolder);
%             fprintf(globalOutputID, '\n  Run %2i of method %15s ended with status %3i', j, algorithm{1}, status);
%             results(iRun).method = algorithm;
%             results(iRun).strrun = [algorithm{1} ', Run ' num2str(j)];
%             results(iRun).run = j;
%             results(iRun).dataSetSize = OptimizerOptions.dataSetSize;
%             results(iRun).miniBatchSize = OptimizerOptions.miniBatchSize;
%             results(iRun).MaxIter = OptimizerOptions.MaxIter;
%             results(iRun).barrier = OptimizerOptions.barrier;
%             results(iRun).restriction = OptimizerOptions.restriction;
%         end
%     end
%     
%     % Post-processing of results
%     fprintf(1, '   ...and writing summary\n');
%     save('resultsEC.mat', 'results');
%     writeBenchmarkSummary('enzymaticCatalysis', results, resultsfolder, 100, miniBatchSize, ModelSpec);

    
    
    %% JAK2/STAT5 example based on Swameye et al. (2003)
    
    fprintf(1, 'JAK2/STAT5 Swameye model...\n');
    
    % Add the path for the enzymatic example
    addpath('./jakstatSwameye');
    fprintf(globalOutputID, 'Benchmarking for the JAK2/STAT5 (Swameye) example:\n');
    
    % Set model specifications
    ModelSpec = writeModelSpec_JSS();
    
%     % Wrapping the AMICI model
%     [exdir,~,~]=fileparts(which('mainJakstatSignaling.m'));
%     amiwrap('jakstatSwameye','jakstatSwameye_syms', exdir);
    
    % Write Data and initial parameters for enzymatic catalysis
    fprintf(1, '   ...writing data\n');
    writeArtificialData_JSS(ModelSpec);
    
    % Get data and initial concentrations, prepare optimization
    fprintf(1, '   ...loading data\n');
    data = getArtificialData_JSS();
    con0 = getConditions_JSS();
    
    % Do one test run with fmincon to have a solid benchmark
    fprintf(1, '   ...running fmincon\n');
    OptimizerOptions = getOptimizerOptions('fmincon', [], ModelSpec);
    tic;
    [status, results(1)] = evaluateMinibatchOptimization_JSS(data, con0, ModelSpec, 'fmincon', OptimizerOptions, resultsfolder);
    disp(toc);
    
    % Write results to an output file
    fprintf(globalOutputID, '\n  The fmincon benchmarking run ended with status %3i', status);
    
    % Do runs for different algorithms and tuning parameters
    fprintf(1, '   ...running DELOS...\n');
    miniBatchSize = 2;
    iRun = 1;
    
    for algorithm = algorithms
        
        fprintf(1, '      ...with %s...\n', algorithm{1});
        
        % Get the tuning parameters for the current optimization algorithm
        OptimizerOptions = getOptimizerOptions(algorithm{1}, miniBatchSize, ModelSpec);
        
        % Run through all optimizer options for the current algorithm
        for j = 1 : length(OptimizerOptions)
            iRun = iRun + 1;
            tic;
            [status, results(iRun)] = evaluateMinibatchOptimization_JSS(data, con0, ModelSpec, 'delos', OptimizerOptions(j), resultsfolder);
            disp(toc);
            fprintf(globalOutputID, '\n  Run %2i of method %15s ended with status %3i', j, algorithm{1}, status);
            results(iRun).method = algorithm;
            results(iRun).strrun = [algorithm{1} ', Run ' num2str(j)];
            results(iRun).run = j;
            results(iRun).dataSetSize = OptimizerOptions.dataSetSize;
            results(iRun).miniBatchSize = OptimizerOptions.miniBatchSize;
            results(iRun).MaxIter = OptimizerOptions.MaxIter;
            results(iRun).barrier = OptimizerOptions.barrier;
            results(iRun).restriction = OptimizerOptions.restriction;
        end
    end
    
    % Post-processing of results
    fprintf(1, '   ...and writing summary\n');
    save('resultsJSS.mat', 'results');
    writeBenchmarkSummary('jakstatSwameye', results, resultsfolder, 10, miniBatchSize, ModelSpec);
    
    
    
    %% Finishing the benchmark
    % Close output file
    fclose(globalOutputID);
    fprintf(1, 'Done!\n');
    
end
