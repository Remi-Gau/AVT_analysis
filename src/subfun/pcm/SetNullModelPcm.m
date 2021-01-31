% (C) Copyright 2021 Remi Gau

function M = SetNullModelPcm(M, NbConditions)

    % null model
    M{1}.type       = 'feature';
    M{1}.Ac = [];
    M{1}.Ac = zeros(NbConditions, 1);
    M{1}.numGparams = size(M{1}.Ac, 3);
    M{1}.name       = 'null';
    M{1}.fitAlgorithm = 'minimize';

end
