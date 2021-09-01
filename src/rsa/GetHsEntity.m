function hs_entity = GetHsEntity(NbHs, hs)
    %
    % (C) Copyright 2021 Remi Gau
    hs_entity = '';
    if NbHs == 1
        return
    else
        hs_entity = '_hemi-';
        if hs == 1
            label = 'L';
        else
            label = 'R';
        end
        hs_entity = [hs_entity label];
    end
end
