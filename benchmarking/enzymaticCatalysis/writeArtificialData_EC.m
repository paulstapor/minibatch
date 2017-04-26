
% Function for writing artificial data and initial concentrations for the
% enzymatic catalysis model.
% The ModelSpec struct is needed to write the data.
% Data is written to matlab files, which can be called to get the data.

function writeArtificialData_EC(ModelSpec)

    % Process input
    theta = ModelSpec.theta;
    sigma2 = ModelSpec.sigma2;
    nTimepoints = ModelSpec.nTimepoints;
    nMeasure = ModelSpec.nMeasure;
    
    % Set folder correctly
    [exdir,~,~]=fileparts(which('writeArtificialData_EC.m'));

    %% Creation of initial concentrations
    % Writing the initial concentrations using a log-normal distribution
    con0 = exp(normrnd(0, 0.5, 4, nMeasure));

    % Create file with initial concentrations
    fid = fopen([exdir '/getConditions_EC.m'], 'w');
    fprintf(fid, 'function con0 = getConditions_EC()\n\n');
    fprintf(fid, ['    con0 = nan(4, ' num2str(nMeasure) ');\n']);

    % Write initial concentrations
    for iMeasure = 1 : nMeasure
        fprintf(fid, ['    con0(:, ' num2str(iMeasure) ') = [']);
        fprintf(fid, '%11.7f; %11.7f; %11.7f; %11.7f];\n', ...
            con0(1, iMeasure), con0(2, iMeasure), con0(3, iMeasure), con0(4, iMeasure));
    end

    % Close file
    fprintf(fid, '\n end');
    fclose(fid);

    %% Creation of measurement data
    % Right hand side of the ODE
    f = @(theta, x) [...
        - theta(1)*x(1)*x(2) + theta(2)*x(3);...
        - theta(1)*x(1)*x(2) + (theta(2)+theta(3))*x(3) - theta(4)*x(2)*x(4);...
          theta(1)*x(1)*x(2) - (theta(2)+theta(3))*x(3) + theta(4)*x(2)*x(4);...
          theta(3)*x(3) - theta(4)*x(2)*x(4)];

    % Creation of the time vector and the observable function
    t = linspace(0, 5, nTimepoints);
    h = @(x,theta) [x(:,1), x(:,4)];

    % Create file with measurement data
    fid = fopen([exdir '/getArtificialData_EC.m']', 'w');
    fprintf(fid, 'function yMeasure = getArtificialData_EC()\n\n');
    fprintf(fid, ['yMeasure = nan(' num2str(nMeasure) ', ' num2str(nTimepoints) ' , 2);\n']);

    % Write the Measruement data
    for iMeasure = 1 : nMeasure                
        [~,X] = ode15s(@(t,x) f(exp(theta),x), t, con0(:,iMeasure));
        y = h(X(:,1:4), exp(theta));
        y = y + normrnd(0, sqrt(sigma2), nTimepoints, 2);
        for iTime = 1 : nTimepoints
            fprintf(fid, ['yMeasure(' num2str(iMeasure) ', ' num2str(iTime) ', :) = [']);
            fprintf(fid, num2str(y(iTime, :)));
            fprintf(fid, '];\n');
        end
    end

    % Close file
    fprintf(fid, '\n end');
    fclose(fid);

end