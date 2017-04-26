
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
    
    %% Enzymatic catalysis example
    
    % Add the path for the enzymatic example
    addpath('./enzymaticCatalysis');
    
    % Set model specifications
    ModelSpec = writeModelSpec_EC();
    
    % Write Data and initial parameters for enzymatic catalysis
    % writeArtificialData_EC(ModelSpec);;
    
    % Get data and initial concentrations, prepare optimization
    data = getArtificialData_EC();
    con0 = getConditions_EC();
    
    % Do one test run with fmincon to have a solid benchmark
    OptimizerOptions = getOptimizerOptions('fmincon', [], ModelSpec);
    status = evaluateMinibatchOptimization_EC(data, con0, ModelSpec, 'fmincon', OptimizerOptions);
    
    fprintf('\n  The fmincon benchmarking run ended with status %3i', status);
    
    % Do runs for different algorithms and tuning parameters
    algorithms = {'adam'}; % {'rmsprop', 'rmspropnesterov', 'adam', 'adadelta'};
    for algorithm = algorithms
        
        % Get the tuning parameters for the current optimization algorithm
        OptimizerOptions = getOptimizerOptions(algorithm{1}, miniBatchSize, ModelSpec);
        
        % Run through all optimizer options for the current algorithm
        for j = 1 : length(OptimizerOptions)
            status = evaluateMinibatchEnzymaticCatalysis(data, con0, ModelSpec, 'delos', OptimizerOptions(j));
            fprintf('\n  Run %2i of method %15s ended with status %3i', j, algorithm{1}, status);
        end
    end
    
end
