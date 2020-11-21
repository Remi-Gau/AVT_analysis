% (C) Copyright 2020 Remi Gau
function DesMat = SetDesignMatLamGlm(NbLayers, Quad)
    %
    % Creates a design matrix for the laminar GLM. The regressors are orthogonalized
    % with respect to the first regressor (that of the constant).
    %
    % USAGE::
    %
    %   DesMat = SetDesignMatLamGlm(NbLayers [, Quad == false])
    %
    % :param NbLayers: number of layers in the model
    % :type NbLayers: positive integer
    % :param Quad: Indicates if a quadratic component should be included in the 
    %              model.
    % :type Quad: boolean
    %
    % :returns:
    %           :DesMat: (array) design matrix with dimension (NbLayers x m)
    %

    DesMat = (1:NbLayers) - mean(1:NbLayers);

    if nargin < 2 || ~Quad
        DesMat = [ones(NbLayers, 1) DesMat'];
    else
        DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
    end

    DesMat = spm_orth(DesMat);

end
