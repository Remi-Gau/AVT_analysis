% (C) Copyright 2020 Remi Gau

function M = PrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual)

    if strcmpi(AuditoryOrVisual, 'auditory')
        Cdt = 1:2;
    else
        Cdt = 3:4;
    end

    if IpsiContraScaled == 1
        col_num = [1 1];
    else
        col_num = [1 2];
    end

    for i = 1:numel(Cdt)
        
        M = SetFeatureThisCondition(M, NbConditions, col_num, Cdt(i));
        
        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, NbConditions, col_num, i, Cdt(i));

    end

end