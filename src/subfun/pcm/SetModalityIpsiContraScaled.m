% (C) Copyright 2021 Remi Gau

function M = SetModalityIpsiContraScaled(M, Modality, Scaled)
    
    switch Modality
        
        case 'A'    
            RowToAdd = [1 2];
            
        case 'V'       
            RowToAdd = [3 4];
            
        case 'T'
            RowToAdd = [5 6];
            
    end
    
    % default is ipsi and contra are independent
    ColToAdd = [size(M{end}.Ac, 2)+1, size(M{end}.Ac, 2)+2];
    if Scaled
        ColToAdd = repmat(size(M{end}.Ac+1, 2)+1, 1, 2);
    end
    
    for iCdt = 1:numel(RowToAdd)
    
        M = SetFeatureThisCondition(M, ColToAdd(iCdt), RowToAdd(iCdt));
    
    end
    
end