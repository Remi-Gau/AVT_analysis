function [B] = laminar_glm(X, Y)
    % runs a laminar GLM to decompose a laminar profile into a constant, a
    % linear (and a quadratic component).
    % If the X is unspecified we assume 6 laminae and a design matrix

    if isempty(X)
        NbLayers = 6;
        X = set_design_mat_lam_GLM(NbLayers);
    end

    Y = flipud(Y);

    if any(isnan(Y(:)))
        [~, y] = find(isnan(Y));
        y = unique(y);
        Y(:, y) = [];
        clear y;
    end

    if isempty(Y)
        B = nan(1, size(X, 2));
    else
        X = repmat(X, size(Y, 2), 1);
        Y = Y(:);
        [B, ~, ~] = glmfit(X, Y, 'normal', 'constant', 'off');
    end

end
