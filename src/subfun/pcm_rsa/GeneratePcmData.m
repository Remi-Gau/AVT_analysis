function [Y0, Y1] = GeneratePcmData(Z, G, s, sig, NbFeatures, X, B)
    %
    % USAGE::
    %
    %  [Y0, Y1] = GeneratePcmData(Z, G, s, sig, NbFeatures, X, B)
    %
    % (C) Copyright 2020 Remi Gau

    if nargin < 6 || isempty(X) || isempty(B)
        Do_fixed_effect = 0;
    else
        Do_fixed_effect = 1;
    end

    % Johanna's way
    % U ~ N( 0, G )
    % Y ~ Z * U + X * B + epsilon
    %         MScon=mvnrnd(zeros(1,NbCdt),G,NbFeatures)';
    %         Y_ms=Z*MScon;
    %
    %         % add noise
    %         Y_ms_n=Y_ms{tr}+sigmodel*demean(randn(NbSess*NbCdt,NbFeatures),2);
    %
    %         % add mean
    %         Y_ms_n_mc=Y_ms_n+meanadd;

    % y_{.j} ~ N( X*b_{.j}, V(theta) )
    % V(theta) =  Z*G*s*Z' + I*(sig_{eps})^2
    % theta = { s , (sig_{eps})^2 }

    V = Z * G * s * Z';
    V = V + eye(size(V)) * sig;

    % data with no fixed effect
    Y0 = mvnrnd(zeros(1, size(Z, 1)), V, NbFeatures)';

    % data with fixed effect
    if Do_fixed_effect
        Y1 = mvnrnd(X * B, V, NbFeatures)';
    end

end
