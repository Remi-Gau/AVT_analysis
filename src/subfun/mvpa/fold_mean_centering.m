function data = fold_mean_centering(data, folds_list, folds)
    %
    % (C) Copyright 2020 Remi Gau

    for isess = 1:numel(folds_list)
        fold_to_center = find(folds == folds_list(isess));
        mnval = mean(data(fold_to_center, :));
        for i = 1:numel(fold_to_center)
            data(fold_to_center(i), :) = data(fold_to_center(i), :) - mnval;
        end
    end
end
