function du = ComputeUnbiasedEffectSize(Data)
    % using bias correction of effect size estimate (Hedges and Olkin)
    % from DOI 10.1177/0013164404264850
    d = mean(Data) / std(Data);
    nu = length(Data) - 1;
    G = gamma(nu / 2) / (sqrt(nu / 2) * gamma((nu - 1) / 2));
    du = d * G;
end
