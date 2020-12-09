% (C) Copyright 2020 Remi Gau

function du = ComputeUnbiasedEffectSize(Data)
    %
    % Computes an unbiased estimate of the effect size
    % using bias correction (by Hedges and Olkin)
    % from <https://doi.org/10.1177/0013164404264850>
    %
    % See also Daniel Lakens: <https://doi.org/10.3389/fpsyg.2013.00863>
    %
    % USAGE::
    %
    %   du = ComputeUnbiasedEffectSize(Data)
    %
    %

    d = mean(Data) / std(Data);
    nu = length(Data) - 1;
    G = gamma(nu / 2) / (sqrt(nu / 2) * gamma((nu - 1) / 2));
    du = d * G;
end
