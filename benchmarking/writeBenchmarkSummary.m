
% Function writing a short summary of optimization results.
%
% Optimization is carried out in minibatch e.g. stocahstic mode.
%
% The best nResults runs are written down in a textfile and plotted.

function writeBenchmarkSummary(model, results, resultsfolder, nResults, miniBatchSize, ModelSpec)
    
    % Read out values from results struct
    runs = length(results)-1;
    nOutputs = min(runs, nResults);
    bestValues = zeros(1,runs);
    meanValues = zeros(1,runs);
    medianValues = zeros(1,runs);
        
    % Opening the output file
    summaryID = fopen([resultsfolder '/benchmarkSummary_' model '.txt'], 'w');
    
    % Writing
    fprintf(summaryID, '============================================\n');
    fprintf(summaryID, ' Summary of DELOS Optimization Benchmarking \n');
    fprintf(summaryID, '     %25s Example      \n', model);
    fprintf(summaryID, '============================================\n\n');
    fprintf(summaryID, 'Date and time: %s \n\n', datetime);
    
    % Printing fmincon results
    fprintf(summaryID, 'Results from fmincon optimization:\n');
    fprintf(summaryID, 'Best Optimum:     %18.7f\n', results(1).bestOptimum);
    fprintf(summaryID, 'Mean of Optima:   %18.7f\n', results(1).meanOptimum);
    fprintf(summaryID, 'Median of Optima: %18.7f\n', results(1).medianOptimum);
    fprintf(summaryID, 'Runtime in min:   %18.7f\n\n\n', results(1).runtime / 60);
    
    % Printing best results
    fprintf(summaryID, 'Results from delos optimization:\n');
    
    % Sorting the results
    results(1) = [];
    for j = 1 : runs
        bestValues(j) = results(j).bestOptimum;
        meanValues(j) = results(j).meanOptimum;
        medianValues(j) = results(j).medianOptimum;
    end
    
    % Best medians
    fprintf(summaryID, '\nBest found optimum medians:\n');
    [medianOptima, medianInidices] = sort(medianValues);
    for j = 1 : nOutputs
        fprintf(summaryID, '  LLH = %18.7f, %25s\n', medianOptima(j), results(medianInidices(j)).strrun);
    end
    
    % Best global optima
    fprintf(summaryID, '\nBest found global optima:\n');
    [bestOptima, bestInidices] = sort(bestValues);
    for j = 1 : nOutputs
        fprintf(summaryID, '  LLH = %18.7f, %25s\n', bestOptima(j), results(bestInidices(j)).strrun);
    end

    % Best means
    fprintf(summaryID, '\nBest found optimum means:\n');
    [meanOptima, meanInidices] = sort(meanValues);
    for j = 1 : nOutputs
        fprintf(summaryID, '  LLH = %18.7f, %25s\n', meanOptima(j), results(meanInidices(j)).strrun);
    end
    
    % Write tuning parameters for best median results
    fprintf(summaryID, '\n\nSpecifications for results for best median values:\n\n');
    
    for j = 1 : nOutputs
        fprintf(summaryID, 'Result %i:\n\n', j);
        clear OptimizerOptions;
        OptimizerOptions = getOptimizerOptions(results(medianInidices(j)).method{1}, miniBatchSize, ModelSpec);
        
        fprintf(summaryID, 'Algorithm: %s\n', results(medianInidices(j)).method{1});
        fprintf(summaryID, 'Runtime in minutes: %18.7f\n', results(medianInidices(j)).runtime / 60);
        fprintf(summaryID, 'Optimization options:\n');
        fprintf(summaryID, '  dataSetSize: %i\n', results(medianInidices(j)).dataSetSize);
        fprintf(summaryID, '  miniBatchSize: %i\n', results(medianInidices(j)).miniBatchSize);
        fprintf(summaryID, '  MaxIter: %i\n', results(medianInidices(j)).MaxIter);
        fprintf(summaryID, '  barrier: %s\n', results(medianInidices(j)).barrier);
        fprintf(summaryID, '  restriction: %i\n', results(medianInidices(j)).restriction);
        
        fprintf(summaryID, 'Tuning parameters (hyperparameters):\n');
        tuningFields = fieldnames(OptimizerOptions(results(medianInidices(j)).run).hyperparams);
        for iField = 1 : numel(tuningFields)
            fprintf(summaryID, '  %s: %f\n', tuningFields{iField}, OptimizerOptions(results(medianInidices(j)).run).hyperparams.(tuningFields{iField}));
        end
        fprintf(summaryID, '\n');
    end
    
    % Closing the file
    fclose(summaryID);
    
end