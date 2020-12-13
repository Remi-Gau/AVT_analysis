% (C) Copyright 2020 Remi Gau

function M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, NbConditions, col_num, Value2Check, RowToAdd)
    
    if IpsiContraScaled == 2 && mod(Value2Check, 2) == 0
        
        A = zeros(1, NbConditions);
        A(RowToAdd) = 1;
        M{end}.Ac(:, col_num(Value2Check) - 1, end + 1) = A;
        
    end
    
end