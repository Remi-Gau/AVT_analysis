% (C) Copyright 2020 Remi Gau

function M = AllScaled(M, IpsiContraScaled)

    NbConditions = 6;

    if IpsiContraScaled == 1
        col_num = [1 1 1 1 1 1];
    else
        col_num = [1 2 1 2 1 2];
    end

    for i = 1:numel(NbConditions)

        M = SetFeatureThisCondition(M, col_num, i);

        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, col_num, i, i);

    end

end
