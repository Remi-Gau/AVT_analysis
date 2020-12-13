% (C) Copyright 2020 Remi Gau

function M = NonPrefIdpdt(M, NbConditions, IpsiContraScaled)

    Cdt = 5:6;

    if mod(size(M{end}.Ac, 2), 2) == 0
        ColToAppend = size(M{end}.Ac, 2) + 1;
    else
        ColToAppend = size(M{end}.Ac, 2) + 2;
    end

    if IpsiContraScaled == 1
        col_num = [ColToAppend ColToAppend];
    else
        col_num = [ColToAppend ColToAppend + 1];
    end

    for i = 1:2
        
        M = SetFeatureThisCondition(M, NbConditions, col_num, Cdt(i));
        
        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, NbConditions, col_num, i, Cdt(i));
        
    end

end