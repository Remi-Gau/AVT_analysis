% (C) Copyright 2020 Remi Gau

function M = AllScaledWithPrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual)

    M = PrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);

    if IpsiContraScaled == 1
        col_num = [1 1 1 1 1 1] + size(M{end}.Ac, 2);
    else
        col_num = [1 2 1 2 1 2] + size(M{end}.Ac, 2);
    end

    for i = 1:NbConditions

        M = SetFeatureThisCondition(M, NbConditions, col_num, i);

        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, NbConditions, col_num, i, i);

    end

end