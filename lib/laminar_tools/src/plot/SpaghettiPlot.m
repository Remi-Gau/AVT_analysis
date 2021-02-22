% (C) Copyright 2020 Remi Gau
function SpaghettiPlot(ToPlot)

    % To plot 2 condtions against each other with a spagetthi plot or
    % a bivariate plot

    fontsize = 9;

    m = ToPlot.m;
    n = ToPlot.n;
    SubPlots = ToPlot.SubPlots;

    COLOR_ROIS = RoiColours();

    for iRow = 1:size(ToPlot.Legend, 1)

        fig = figure('Name', 'test');

        SetTightFigure();

        for iColumn = 1:size(SubPlots, 2)

            % main plot
            plot_lines(NbROI, ToPlot, iRow, iColumn, ROIs_to_plot, 0);

            %% plot betas constant or bi-variate results

            if ToPlot.bivariate_subplot == 1

                for cst_lin = 0:1

                    subplot(m, n, SubPlots{2, iColumn} + cst_lin);

                    hold on;

                    MINMAX = [];

                    for iROI = ROIs_to_plot

                        X = ToPlot.profile(iRow, iColumn).beta(:, iROI, 1 + cst_lin);
                        Y = ToPlot.profile(iRow, iColumn + 1).beta(:, iROI, 1 + cst_lin);

                        if cst_lin
                            X = X * -1;
                            Y = Y * -1;
                        end

                        scatter(X, Y, 50, line_colors(iROI, :), 'o');

                        XNEG = std(X);
                        XPOS = std(X);

                        YNEG = std(Y);
                        YPOS = std(Y);

                        l = errorbar(mean(X), mean(Y), YNEG, YPOS, XNEG, XPOS);
                        set(l, ...
                            'color', line_colors(iROI, :), ...
                            'LineWidth', 1.5, ...
                            'Marker', 'o', ...
                            'MarkerFaceColor', line_colors(iROI, :));

                        MINMAX = [MINMAX; X; Y; XNEG; XPOS; YNEG; YPOS]; %#ok<AGROW>

                    end

                    % add some lines
                    plot ([-10 10], [-10 10], '--k'); % diagonal
                    plot ([-10 +10], [0 0], '-k'); %
                    plot ([0 0], [-10 +10], '-k'); %

                    MAX = max(MINMAX) * 1.1;
                    MIN = min(MINMAX) * 1.1;

                    axis([MIN MAX MIN MAX]);

                    set(gca, ...
                        'XTick', get(gca, 'Ytick'), ...
                        'XTickLabel', get(gca, 'YTickLabel'));

                    xlabel(['s parameter - ' ToPlot.bivariate_subplot_legend{iRow, 1}{1}]);
                    ylabel(['s parameter - ' ToPlot.bivariate_subplot_legend{iRow, 1}{2}]);

                    axis square;

                    switch cst_lin
                        case 0
                            Title = 'constant';
                        case 1
                            Title = 'linear';
                    end
                    title(Title);

                end

            else

                for cst_lin = 1:2

                    % plot betas constant
                    subplot(m, n, SubPlots{cst_lin + 1, iColumn});

                    hold on;

                    if ToPlot.bivariate_subplot == 2

                        spaghetti_plot(ToPlot, iRow, iColumn, cst_lin);

                    else

                        Data = ToPlot.profile(iRow, iColumn).beta(:, ROIs_to_plot, cst_lin);

                        if cst_lin == 2 && MVPA_BOLD == 1
                            Data = Data * -1;
                        end

                        if isfield(ToPlot, 'MinMax')
                            ToPlot.MIN = ToPlot.MinMax{cst_lin + 1, iRow}(iColumn, 1);
                            ToPlot.MAX = ToPlot.MinMax{cst_lin + 1, iRow}(iColumn, 2);
                        end

                        plot_betas(Data, ToPlot, fontsize, iRow, iColumn, cst_lin);

                    end

                    if cst_lin == 1
                        t = ylabel(sprintf('constant\nS Param. est. [a u]'));
                    else
                        t = ylabel(sprintf('linear\nS Param. est. [a u]'));
                    end

                    set(t, 'fontsize', fontsize);

                end

            end

        end

        mtit(ToPlot.Titles{iRow, 1}, 'xoff', 0, 'yoff', +0.04, 'fontsize', fontsize + 4);

        print(fig, fullfile(ToPlot.FigureFolder, ...
                            ['All_ROIs_' ToPlot.avg_hs '_' ToPlot.plot_main '_'...
                             strrep(fig.Name, '\n', '-'), suffix, '.tif']), '-dtiff');

    end

end

function spaghetti_plot(ToPlot, iRow, iColumn, cst_lin)

    if strcmp(ToPlot.plot_main, '')
        Xpos = [ ...
                1 2.5; ...
                5 6.5; ...
                10 11.5; ...
                14 15.5];
    else
        Xpos = [ ...
                1 2.5; ...
                5 6.5; ...
                1 2.5; ...
                5 6.5];
    end

    [ROIs_to_plot, NbROI] = find_rois(ToPlot.profile(iRow, iColumn));

    Alpha = 0.05 / NbROI;

    for iROI = ROIs_to_plot

        X = ToPlot.profile(iRow, iColumn).beta(:, iROI, cst_lin);
        Y = ToPlot.profile(iRow, iColumn + 1).beta(:, iROI, cst_lin);

        if cst_lin == 2
            X = X * -1;
            Y = Y * -1;
        end

        abscissa = [ones(size(X))' * Xpos(iROI, 1); ones(size(Y))' * Xpos(iROI, 2)];

        plot(abscissa, [X'; Y'], 'o-', 'color', ToPlot.line_colors(iROI, :));

        for i = 1:2
            if i == 1
                Data = X;
                offset = Xpos(iROI, 1) - .5;
            elseif i == 2
                Data = Y;
                offset = Xpos(iROI, 2) + .5;
            end

            plot(offset, nanmean(Data), 'o', ...
                 'MarkerSize', 5, ...
                 'MarkerFaceColor', ToPlot.line_colors(iROI, :), ...
                 'color', ToPlot.line_colors(iROI, :));

            CI = bootci(10000, {@(x) mean(x), Data}, 'alpha', Alpha, 'type', 'bca');
            Lower = CI(1);
            Upper = CI(2);

            plot( ...
                 [offset; offset], ...
                 [Lower; Upper], ...
                 'color', ToPlot.line_colors(iROI, :), 'LineWidth', 2.5);
        end

    end

    plot([min(Xpos(:)) - 1 max(Xpos(:)) + 1], [0 0], '-k');

    switch cst_lin
        case 1
            Title = 'constant';
        case 2
            Title = 'linear';
    end
    title(Title);

    set(gca, 'xtick', sort(unique(Xpos(:))), ...
        'xticklabel', ...
        {ToPlot.bivariate_subplot_legend{iRow, 1}{1}; ...
         ToPlot.bivariate_subplot_legend{iRow, 1}{2}; ...
         ToPlot.bivariate_subplot_legend{iRow, 1}{1}; ...
         ToPlot.bivariate_subplot_legend{iRow, 1}{2}}, ...
        'fontsize', 8);

end

function plot_betas(Data, ToPlot, fontsize, iCdt, iColumn, S_param)

    [ROIs_to_plot, NbROI] = find_rois(ToPlot.profile(iCdt, iColumn));

    Alpha = 0.05 / NbROI;

    Xpos = [1 3 6:2:14];
    Xpos = Xpos(1:NbROI);

    % plot zero line

    % plot spread
    tmp_cell = mat2cell(Data, size(Data, 1), ones(1, size(Data, 2)));
    for i = 1:numel(Xpos)
        distributionPlot(tmp_cell{i}, 'xValues', Xpos(i), ...
                         'color', ToPlot.line_colors(ROIs_to_plot(i), :), ...
                         'distWidth', 1.2, 'showMM', 0, ...
                         'globalNorm', 2);
        h = plotSpread(tmp_cell{i}, 'distributionMarkers', {'.'}, ...
                       'xValues', Xpos(i), 'binWidth', 1, 'spreadWidth', 1);
        set(h{1}, 'MarkerSize', 10, 'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', 'k', 'LineWidth', 1);
    end

    % plot mean+SEM
    plot(Xpos - .8, nanmean(Data), 'k. ', 'MarkerSize', 18);

    for i = 1:numel(Xpos)

        Lower = nanmean(Data(:, i)) - nansem(Data(:, i));
        Upper = nanmean(Data(:, i)) + nansem(Data(:, i));

        plot( ...
             [Xpos(i) - .8; Xpos(i) - .8], ...
             [Lower; Upper], ...
             ' k', 'LineWidth', 2.5);
    end

    axis tight;
    ax = axis;
    if isfield(ToPlot, 'MinMax')
        MIN = ToPlot.MIN;
        MAX = ToPlot.MAX;
    else
        MIN = ax(3);
        MAX = ax(4) * 1.1;
    end

    if ToPlot.MVPA_BOLD == 2 && ToPlot.Cst
        Data = Data - .5;
    end

    axis([-.4 Xpos(end) + .8 MIN MAX]);

    set(gca, 'tickdir', 'out', 'xtick', Xpos, 'xticklabel', ToPlot.ROIs_name(ROIs_to_plot), ...
        'ticklength', [0.01 0.01], 'fontsize', fontsize - 1, 'FontName', 'Arial');

end

function [ROIs_to_plot, NbROI] = find_rois(profile)
    if isfield(profile, 'main')
        ROIs_to_plot = profile.main;
    else
        ROIs_to_plot = 1:size(profile.MEAN, 2);
    end
    NbROI = numel(ROIs_to_plot);
end
