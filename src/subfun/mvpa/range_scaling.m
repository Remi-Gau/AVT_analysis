function data = range_scaling(data, maxval, minval)
    %
    % (C) Copyright 2020 Remi Gau

    for i = 1:size(data, 1)
        data(i, :) = 2 * (data(i, :) - minval) ./ (maxval - minval) - 1;
    end
end
