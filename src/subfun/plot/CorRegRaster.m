function [rho, slope] = CorRegRaster(Profiles, DesMat, iToPlot, X_sort)
    for iPerc = 1:size(Profiles, 1)
        Y = squeeze(Profiles(iPerc, :, :));

        X = [];
        for iSubj = 1:size(Y, 2)
            if size(DesMat, 2) == 3
                X((1:6) + 6 * (iSubj - 1), (1:3) + 3 * (iSubj - 1)) = DesMat;
            else
                X((1:6) + 6 * (iSubj - 1), (1:2) + 2 * (iSubj - 1)) = DesMat;
            end
        end

        Y = Y(:);
        B = pinv(X) * Y;

        if size(DesMat, 2) == 3
            Cst_tmp = B(1:3:size(X, 2), :);
            Lin_tmp = B(2:3:size(X, 2), :);
            Quad_tmp = B(3:3:size(X, 2), :);
        else
            Cst_tmp = B(1:2:size(X, 2), :);
            Lin_tmp = B(2:2:size(X, 2), :);
            Quad_tmp = B(3:3:size(X, 2), :);
        end

        if iToPlot == 1
            Y_sort(:, iPerc, :) = Cst_tmp;
        elseif iToPlot == 2
            Y_sort(:, iPerc, :) = Lin_tmp;
        elseif    iToPlot == 3
            Y_sort(:, iPerc, :) = Quad_tmp;
        end

    end

    for iSubj = 1:size(Y_sort, 1)
        R = corrcoef(X_sort(iSubj, :), Y_sort(iSubj, :));
        rho(iSubj) = R(1, 2);
        beta = glmfit(X_sort(iSubj, :), Y_sort(iSubj, :), 'normal');
        slope(iSubj) = beta(2);
    end
end
