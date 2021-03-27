% (C) Copyright 2020 Remi Gau

function [NewColorMap] = NonCenteredDivergingColorMap(Mat2Plot, ColorMap)
    % Takes a diverging colormap and truncates it to remove useless values

    MIN = min(Mat2Plot(:));
    MAX = max(Mat2Plot(:));
    [AbsMax, Idx] = max(abs([MIN MAX]));
    Scale = linspace(-1 * AbsMax, AbsMax, size(ColorMap, 1))';
    if Idx == 2
        if MIN > 0
            MIN = 0;
        end
        Idx = Scale < MIN;
        NewColorMap = ColorMap(~Idx, :);
    else
        if MAX < 0
            MAX = 0;
        end
        Idx = Scale > MAX;
        NewColorMap = ColorMap(~Idx, :);
    end

end
