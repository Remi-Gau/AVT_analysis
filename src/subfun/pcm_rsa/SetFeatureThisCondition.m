% (C) Copyright 2020 Remi Gau

function M = SetFeatureThisCondition(M, ColToAdd, RowToAdd)

    NbConditions = 6;

    A = zeros(1, NbConditions);
    A(RowToAdd) = 1;
    M{end}.Ac(:, ColToAdd, end + 1) = A;

end
