function [Min, Max, Margin] = ComputeMargin(Min, Max, Proportion)
    %
    % Computes a margin that is a proportion larger of a Min-Max Range
    %

    if nargin < 3 || isempty(Proportion)
        Proportion = 1.1;
    end

    Range = (Max - Min);
    Margin = (Range * Proportion  - Range) / 2;
    Max = Max + Margin;
    Min = Min - Margin;

end
