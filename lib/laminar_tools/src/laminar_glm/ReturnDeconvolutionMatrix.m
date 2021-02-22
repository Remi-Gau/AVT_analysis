% (C) Copyright 2021 Remi Gau

function X = ReturnDeconvolutionMatrix(nb_layers, peak, tail)
    %
    %
    % adapted from simulation code from Uta Noppeney

    X = tril(ones(nb_layers, nb_layers) * tail, -1) + diag(ones(nb_layers, 1) * peak);

end
