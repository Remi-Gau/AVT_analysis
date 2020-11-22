function data = mean_centering(data, mnval)
    for i = 1:size(data, 1)
        data(i, :) = data(i, :) - mnval;
    end
end
