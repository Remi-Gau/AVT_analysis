% (C) Copyright 2020 Remi Gau

function Data = CombineDataBothHemisphere(Data)

    NbSub = size(Data, 1);

    tmp = {};
    for iSub = 1:NbSub
        tmp{iSub, 1} = [Data{iSub, 1} Data{iSub, 2}]; %#ok<*AGROW>
    end
    Data = tmp;

end
