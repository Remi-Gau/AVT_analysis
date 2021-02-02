% (C) Copyright 2021 Remi Gau

function idx = ReturnRoiIndex(Data, RoiName)
    idx = find(strcmp({Data.RoiName}, RoiName));
end