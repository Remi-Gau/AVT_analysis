function SetAxisGMatrix(ConditionNames, FONTSIZE)
    %
    % (C) Copyright 2020 Remi Gau

    set(gca, ...
        'tickdir', 'out', ...
        'xtick', 1:numel(ConditionNames), ...
        'xticklabel', [], ...
        'ytick', 1:numel(ConditionNames), ...
        'yticklabel', ConditionNames, ...
        'ticklength', [0.01 0], ...
        'fontsize', FONTSIZE - 2);
    box off;
    axis square;

    colorbar;
end
