% (C) Copyright 2020 Remi Gau

function M = SetFeatureThisCondition(M, col_num, RowToAdd)

    NbConditions = 6;

    A = zeros(1, NbConditions);
    A(RowToAdd) = 1;
    M{end}.Ac(:, col_num(RowToAdd), end + 1) = A;

end
