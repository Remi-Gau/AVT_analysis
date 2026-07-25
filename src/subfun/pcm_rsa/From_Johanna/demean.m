function xout = demean(xin, dim)
    %
    % (C) Copyright 2016 Johanna Zumer

    if dim == 1
        xout = xin - repmat(mean(xin, dim), [size(xin, 1) 1]);
    elseif dim == 2
        xout = xin - repmat(mean(xin, dim), [1, size(xin, 2)]);
    end
