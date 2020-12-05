% (C) Copyright 2020 Remi Gau
function [betaHat] = RunLaminarGlm(Y, X)
    %
    % Runs a laminar GLM to decompose a laminar profile into a constant, a
    % linear and a quadratic component.
    % 
    %
    % USAGE::
    %
    %   [betaHat] = RunLaminarGlm(Y, X == [])
    %
    % :param X: Indicates if a quadratic component should be included in the
    %           model.
    % :type X: array of dimension m X n, with m = NbLayers and n = number of
    %          parameters in the laminar GLM. If the X is unspecified we assume 6 laminae
    %          and a model with a quadratic component.
    % :param Y: data of dimension m X n, with m = NbSubject * NbRuns and n = NbLayers
    % :type Y: array
    %
    % :returns:
    %           :betaHat: array of estimated beta values of dimension m X n.
    %                     m = number of parameters in the laminar GLM
    %                     n = NbSubject * NbRuns
    %

    if nargin<2
        X = [];
    end

    if isempty(X)
        NbLayers = 6;
        X = SetDesignMatLamGlm(NbLayers, true);
    end
    
    Y = Y';
    Y(:, isnan(Y)) = [];

    betaHat = nan(1, size(X, 2));
    if ~isempty(Y)
        betaHat = pinv(X) * Y;

    end

end
