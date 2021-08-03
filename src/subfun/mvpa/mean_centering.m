function data = mean_centering(data, mnval)
    %
    % (C) Copyright 2020 Remi Gau

    for i = 1:size(data, 1)
        data(i, :) = data(i, :) - mnval;
    end
end
