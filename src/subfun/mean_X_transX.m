% (C) Copyright 2020 Remi Gau
function  Y = mean_X_transX(X)
    % Returns the mean of a X+trans(X)

    Y = nanmean(cat(3, X, X'), 3);

end
