% (C) Copyright 2020 Remi Gau

function M = AllIdpdt(M, IpsiContraScaled)

    NbConditions = 6;

    if IpsiContraScaled == 1
        col_num = [1 1 2 2 3 3];
    else
        col_num = 1:6;
    end

    %     if IpsiContraScaled == 1
    %         col_num = [1 1 2 2 3 3] + size(M{end}.Ac, 2);
    %     else
    %         col_num = (1:6) + size(M{end}.Ac, 2);
    %     end

    for i = 1:NbConditions

        M = SetFeatureThisCondition(M, col_num(i), i);

        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, col_num, i, i);

    end

end
