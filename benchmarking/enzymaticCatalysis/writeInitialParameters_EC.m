
% Function for writing initial parameters for optimization for the 
% enzymatic catalysis model.

% A .mat file is created in which the initial parameters are saved

function ModelSpec = writeInitialParameters_EC(ModelSpec)

    par0 = lhsdesign(ModelSpec.n_starts, 4, 'smooth', 'off')';

end