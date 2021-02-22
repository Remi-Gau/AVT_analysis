% (C) Copyright 2020 Remi Gau
function DesignMatrix = SetDesignMatLamGlm(NbLayers, Quad)
    %
    % Creates a design matrix for the laminar GLM. The regressors are orthogonalized
    % with respect to the first regressor (that of the constant).
    %
    % USAGE::
    %
    %   DesignMatrix = SetDesignMatLamGlm(NbLayers [, Quad == true])
    %
    % :param NbLayers: number of layers in the model
    % :type NbLayers: positive integer
    % :param Quad: Indicates if a quadratic component should be included in the
    %              model.
    % :type Quad: boolean
    %
    % :returns:
    %           :DesignMatrix: (array) design matrix with dimension (NbLayers x m)
    %

    if nargin < 1 || isempty(NbLayers)
        NbLayers = 6;
    end

    if nargin < 2
        Quad = true;
    end

    DesignMatrix = (1:NbLayers) - mean(1:NbLayers);

    if ~Quad
        DesignMatrix = [ones(NbLayers, 1) DesignMatrix'];
    else
        DesignMatrix = [ones(NbLayers, 1) DesignMatrix' (DesignMatrix.^2)'];
    end

    DesignMatrix = spm_orth(DesignMatrix);

end
