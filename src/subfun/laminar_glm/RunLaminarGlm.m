% (C) Copyright 2020 Remi Gau
function [BetaHat] = RunLaminarGlm(Data, DesignMatrix)
    %
    % Runs a laminar GLM to decompose a laminar profile into a constant, a
    % linear and a quadratic component.
    %
    %
    % USAGE::
    %
    %   [betaHat] = RunLaminarGlm(Data, X == [])
    %
    % :param Data: data of dimension m X n, with m = NbSubject * NbRuns and n = NbLayers
    % :type Data: array
    % :param DesignMatrix: Indicates if a quadratic component should be included in the
    %           model.
    % :type DesignMatrix: array of dimension m X n, with m = NbLayers and n = number of
    %          parameters in the laminar GLM. If the X is unspecified we assume 6 laminae
    %          and a model with a quadratic component.
    %
    % :returns:
    %           :betaHat: array of estimated beta values of dimension m X n.
    %                     n = number of parameters in the laminar GLM
    %                     m = NbSubject * NbRuns
    %

    if nargin < 2
        DesignMatrix = [];
    end

    if isempty(DesignMatrix)
        NbLayers = 6;
        DesignMatrix = SetDesignMatLamGlm(NbLayers, true);
    end

    Data = Data';
    
    BetaHat = nan(1, size(DesignMatrix, 2));
    if ~isempty(Data)
        BetaHat = pinv(DesignMatrix) * Data;

    end

    BetaHat = BetaHat';

end
