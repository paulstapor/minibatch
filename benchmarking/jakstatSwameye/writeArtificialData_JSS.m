
% Function for writing artificial data and initial concentrations for the
% enzymatic catalysis model.
% The ModelSpec struct is needed to write the data.
% Data is written to matlab files, which can be called to get the data.

function writeArtificialData_JSS(ModelSpec)

    % Process input
    theta = ModelSpec.theta;
    sigma = ModelSpec.sigma;
    timepoints = ModelSpec.timepoints;
    nMeasure = ModelSpec.nMeasure;
    
    % Set folder correctly
    [exdir, ~, ~] = fileparts(which('writeArtificialData_JSS.m'));

    %% Creation of initial concentrations
    % Writing the initial concentrations using a log-normal distribution
    con0_omegaCyt = exp(normrnd(log(1.4), 0.05, 1, nMeasure));
    con0_omegaNuc = exp(normrnd(log(0.45), 0.03, 1, nMeasure));
    con0_initSTAT = exp(normrnd(0, 0.5, 1, nMeasure));

    % Create file with initial concentrations
    fid = fopen([exdir '/getConditions_JSS.m'], 'w');
    fprintf(fid, 'function con0 = getConditions_JSS()\n\n');
    fprintf(fid, ['    con0 = nan(3, ' num2str(nMeasure) ');\n']);

    % Write initial concentrations
    for iMeasure = 1 : nMeasure
        fprintf(fid, ['    con0(:, ' num2str(iMeasure) ') = [']);
        fprintf(fid, '%11.7f; %11.7f; %11.7f];\n', ...
            con0_omegaCyt(iMeasure), con0_omegaNuc(iMeasure), con0_initSTAT(iMeasure));
    end

    % Close file
    fprintf(fid, '\n end');
    fclose(fid);

    %% Creation of measurement data
    % Simulation routine
    

    % Create file with measurement data
    fid = fopen([exdir '/getArtificialData_JSS.m']', 'w');
    fprintf(fid, 'function yMeasure = getArtificialData_JSS()\n\n');
    fprintf(fid, ['yMeasure = nan(' num2str(nMeasure) ', ' num2str(length(timepoints)) ' , 3);\n']);
    
    ami_options = amioption();
    ami_options.atol = 1e-13;
    ami_options.rtol = 1e-10;
    ami_options.sensi = 0;
   
    sigma_pSTAT = normrnd(0, sigma(1), length(timepoints), nMeasure);
    sigma_tSTAT = normrnd(0, sigma(2), length(timepoints), nMeasure);
    sigma_pEpoR = normrnd(0, sigma(3), length(timepoints), nMeasure);
        
    % Write the Measruement data
    for iMeasure = 1 : nMeasure                
        
        % Create data
        [~, ~, ~, y] = simulate_jakstatSwameye(timepoints, theta, [con0_omegaCyt(iMeasure); con0_omegaNuc(iMeasure); con0_initSTAT(iMeasure)], [], ami_options);
        y = y + [sigma_pSTAT(:,iMeasure), sigma_tSTAT(:,iMeasure), sigma_pEpoR(:,iMeasure)];
        
        for iTime = 1 : length(timepoints)
            fprintf(fid, ['yMeasure(' num2str(iMeasure) ', ' num2str(iTime) ', :) = [']);
            fprintf(fid, num2str(y(iTime, :)));
            fprintf(fid, '];\n');
        end
    end

    % Close file
    fprintf(fid, '\n end');
    fclose(fid);

end