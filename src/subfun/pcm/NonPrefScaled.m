% (C) Copyright 2020 Remi Gau

function M = NonPrefScaled(M, IpsiContraScaled, AuditoryOrVisual)

    if strcmpi(AuditoryOrVisual, 'auditory')
        Cdt = 3:6;
    elseif strcmpi(AuditoryOrVisual, 'visual')
        Cdt = [1 2 5 6];
    end

    if mod(size(M{end}.Ac, 2), 2) == 0
        ColToAppend = size(M{end}.Ac, 2) + 1;
    else
        ColToAppend = size(M{end}.Ac, 2) + 2;
    end

    if IpsiContraScaled == 1
        col_num = repmat(ColToAppend, 1, 4);
    else
        col_num = repmat([ColToAppend, ColToAppend + 1], 1, 2);
    end

    for i = 1:numel(Cdt)

        M = SetFeatureThisCondition(M, col_num, Cdt(i));

        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, col_num, i, Cdt(i));

    end

end
