% (C) Copyright 2020 Remi Gau

function M = SetFeatureThisCondition(M, NbConditions, col_num, RowToAdd)
    
    A = zeros(1, numel(NbConditions));
    A(RowToAdd) = 1;
    M{end}.Ac(:, col_num(RowToAdd), end + 1) = A;
    
end