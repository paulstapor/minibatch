function varargout = logLikelihoodJSS(theta, data, con0, timepoints, miniBatch)
% Objective function for examples/jakstat_signaling
%
% logLikelihoodJakstat.m provides the log-likelihood, its gradient and an 
% the Hessian matrix for the model for the JakStat signaling pathway as
% defined in jakstat_pesto_syms.m
% 
% USAGE:
% [llh] = getParameterProfiles(theta, amiData)
% [llh, sllh] = getParameterProfiles(theta, amiData)
%
% Parameters:
%  theta: Model parameters 
%  amiData: an amidata object for the AMICI solver
%
% Return values:
%   varargout:
%     llh: Log-Likelihood, only the LogLikelihood will be returned, no 
%         sensitivity analysis is performed
%     sllh: Gradient of llh, The LogLikelihood and its gradient will be 
%         returned, first order adjoint sensitivity analysis is performed
%     s2llh: Hessian of llh, The LogLikelihood, its gradient and the 
%         Hessian matrix will be returned, second order adjoint sensitivity 
%         analysis is performed



%% Model Definition
% The ODE model is set up using the AMICI toolbox. To access the AMICI
% model setup, see jakstat_pesto_syms.m
% For a detailed description for the biological model see the referenced
% papers on the JakStat signaling pathway by Swameye et al. and Schelker et
% al.

%% AMICI
% Setting the options for the AMICI solver
amiOptions.rtol = 1e-10;
amiOptions.atol = 1e-13;
amiOptions.sensi_meth = 'adjoint';

% Preallocate
J = 0;
gradJ = zeros(size(theta));

if size(miniBatch, 1) > size(miniBatch, 2)
    miniBatch = transpose(miniBatch);
end

% Loop over the experiments and simulation for each experiment
for iMeasure = miniBatch
    
    % Create amidata object
    amiData.t = timepoints;
    amiData.Y = squeeze(data(iMeasure,:,:));
    amiData.condition = con0(:,iMeasure);
    amiData = amidata(amiData);
    
    % Simulation
    if (nargout == 1)
        amiOptions.sensi = 0;
        sol = simulate_jakstatSwameye(amiData.t, theta, amiData.condition, amiData, amiOptions);
        J = J + sol.llh;  
    elseif (nargout == 2)
        amiOptions.sensi = 1;
        sol = simulate_jakstatSwameye(amiData.t, theta, amiData.condition, amiData, amiOptions);
        J = J + sol.llh;
        gradJ = gradJ + sol.sllh;
    else
        error('Call to objective function with too many outputs');
    end
end

% Normalization by the number of experiments
varargout{1} = J / length(miniBatch);
if (nargout > 1)
    varargout{2} = gradJ / length(miniBatch);
end

end
