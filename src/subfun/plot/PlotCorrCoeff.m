function PlotCorrCoeff(ax, Values2Plot, XTickLabel, XOffSet, YOffSet, XDim, YDim, Axis, ToPermute)

    if nargin < 9
        ToPermute = [];
    end

    axPos = ax.Position;
    axPos(1) = axPos(1) + XOffSet;
    axPos(2) = axPos(2) + YOffSet;
    axPos(3) = XDim;
    axPos(4) = YDim;
    axes('Position', axPos);
    hold on;

    MAX = max(abs(Values2Plot)) * 1.25;
    Axis(3) = MAX * -1;
    Axis(4) = MAX;

    plot([0.9 1.9], [0 0], ':k', 'linewidth', 2);

    if isempty(ToPermute)
        [~, P] = ttest(Values2Plot);
    else
        Perms = ToPermute .* repmat(Values2Plot, [size(ToPermute, 1), 1]);
        Perms = mean(Perms, 2);
        P = sum(abs(Perms - mean(Perms)) > abs(mean(Values2Plot) - mean(Perms))) / numel(Perms);
    end

    if P < 0.001
        Sig = sprintf('\np<0.001 ');
    else
        Sig = sprintf('\np=%.3f ', P);
    end
    t = text(.95, 0.05, sprintf(Sig));
    set(t, 'fontsize', 10);

    if P < .01
        set(t, 'color', 'r');
    end

    h = errorbar(1, mean(Values2Plot), nanstd(Values2Plot), 'o', 'LineStyle', 'none', 'Color', [0 0 0]);
    set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1);

    h = plotSpread(Values2Plot', ...
                   'distributionMarkers', {'.'}, 'distributionColors', {'k'}, ...
                   'xValues', 1.2, 'binWidth', 0.25, 'spreadWidth', 0.6);
    set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineWidth', 1);

    set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
        'xtick', 1.1, 'xticklabel', [], 'ytick', -3:.015:3, 'yticklabel', -3:.015:3, ...
        'ygrid', 'on');
    axis(Axis);

end
