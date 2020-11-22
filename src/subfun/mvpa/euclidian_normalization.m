function data = euclidian_normalization(data)
    for i = 1:size(data, 1)
        data(i, :) = data(i, :) / norm(data(i, :));
    end
end
