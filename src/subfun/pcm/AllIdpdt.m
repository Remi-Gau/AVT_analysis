% (C) Copyright 2020 Remi Gau

function M = AllIdpdt(M, NbConditions, IpsiContraScaled)

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
        
        M = SetFeatureThisCondition(M, NbConditions, col_num, i);
        
        M = SetFeatureIpsiContraScaled(M, IpsiContraScaled, NbConditions, col_num, i, i);
        
    end

end
