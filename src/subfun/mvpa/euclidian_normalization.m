function data = euclidian_normalization(data)
    %
    % (C) Copyright 2020 Remi Gau

    for i = 1:size(data, 1)
        data(i, :) = data(i, :) / norm(data(i, :));
    end
end
