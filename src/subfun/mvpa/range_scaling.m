function data = range_scaling(data, maxval, minval)
    for i = 1:size(data, 1)
        data(i, :) = 2 * (data(i, :) - minval) ./ (maxval - minval) - 1;
    end
end
