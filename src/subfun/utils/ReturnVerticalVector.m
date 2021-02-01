% (C) Copyright 2021 Remi Gau

function Vec = ReturnVerticalVector(Vec)

    if size(Vec, 2) > 1
        Vec = Vec';
    end

end
