% (C) Copyright 2020 Remi Gau
function Plot_BOLD_MVPA_all_ROIs(ToPlot)

    fontsize = 9;

    m = ToPlot.m;
    n = ToPlot.n;
    SubPlots = ToPlot.SubPlots;

    line_colors = [ ...
                   37, 52, 148; ...
                   65, 182, 196; ...
                   0, 94, 45; ...
                   89, 153, 74; ...
                   110, 188, 111; ...
                   184, 220, 143; ...
                   235, 215, 184 ...
                  ] / 255;
    ToPlot.line_colors = line_colors;

    if isempty(ToPlot.ToPermute)
        suffix = '_ttest';
    else
        suffix = '_perm';
    end

    if ~isfield(ToPlot, 'on_same_figure')
        ToPlot.on_same_figure = 0;
    end
    if ~isfield(ToPlot, 'bivariate_subplot')
        ToPlot.bivariate_subplot = 0;
    end

    Name = strrep([ToPlot.TitSuf '--' ToPlot.Name], ' ', '_');
    Name = strrep(Name, '_', '-');

    switch size(SubPlots, 2)
        case 3
            figdim = [50, 50, 1800, 800];
        case 2
            figdim = [50, 50, 1200, 600];
        case 1
            figdim = [50, 50, 600, 600];
    end

    for iRow = 1:size(ToPlot.Legend, 1)

        fig = figure('Name', [Name '\n' ToPlot.Titles{iRow, 1}], ...
                     'Position', figdim, 'Color', [1 1 1], 'Visible', ToPlot.Visible);

        set(gca, 'units', 'centimeters');
        pos = get(gca, 'Position');
        ti = get(gca, 'TightInset');

        set(0, 'defaultAxesFontName', 'Arial');
        set(0, 'defaultTextFontName', 'Arial');

        set(fig, 'PaperUnits', 'centimeters');
        set(fig, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
        set(fig, 'PaperPositionMode', 'manual');
        set(fig, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

        set(fig, 'Visible', ToPlot.Visible);

        for iColumn = 1:size(SubPlots, 2)

            [ROIs_to_plot, NbROI] = find_rois(ToPlot.profile(iRow, iColumn));

            if isfield(ToPlot, 'IsMVPA')
                MVPA_BOLD = 1 + ToPlot.IsMVPA(iRow, iColumn);
            else
                MVPA_BOLD = 1;
            end
            ToPlot.Cst = 0;
            ToPlot.MVPA_BOLD = MVPA_BOLD;

            % plot profiles
            subplot(m, n, SubPlots{1, iColumn});
            PlotRectangle(6, fontsize - 1);
            subplot(m, n, SubPlots{1, iColumn});

            hold on;

            if MVPA_BOLD == 2
                plot([-5 15], [0.5 0.5], '-k', 'linewidth', .8);
            else
                plot([-5 15], [0 0], '-k', 'linewidth', .8);
            end

            plot_lines(NbROI, ToPlot, iRow, iColumn, ROIs_to_plot, 0);

            if ToPlot.on_same_figure
                plot_lines(NbROI, ToPlot, iRow, iColumn + 1, ROIs_to_plot, 1);
            end

            axis tight;
            ax = axis;
            if isfield(ToPlot, 'MinMax')
                MIN = ToPlot.MinMax{1, iRow}(iColumn, 1);
                MAX = ToPlot.MinMax{1, iRow}(iColumn, 2);
            else
                MIN = ax(3) - 0.02;
                MAX = ax(4) + 0.02;
            end
            axis([0.4 6.6 MIN MAX]);

            t = title(ToPlot.Legend{iRow, iColumn});
            set(t, 'fontsize', fontsize + 1);
            clear t;

            set(gca, 'tickdir', 'out', 'xtick', [], ...
                'xticklabel', ' ', 'ticklength', [0.01 0.01], ...
                'fontsize', fontsize - 1);

            if MVPA_BOLD == 1
                t = ylabel('B Param. est. [a u]');
            else
                t = ylabel('Decoding accuracy');
            end
            set(t, 'fontsize', fontsize);
            clear t;

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

                        %                     CI_X = bootci(10000,{@(x) mean(x), X},'alpha', 0.05/NbROI, 'type','bca');
                        %                     XNEG = CI_X(1);
                        %                     XPOS = CI_X(2);

                        XNEG = std(X);
                        XPOS = std(X);

                        %                     CI_Y = bootci(10000,{@(x) mean(x), Y},'alpha', 0.05/NbROI, 'type','bca');
                        %                     YNEG = CI_Y(1);
                        %                     YPOS = CI_Y(2);

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

function plot_lines(NbROI, ToPlot, iRow, iColumn, ROIs_to_plot, dash)

    X_pos = repmat((1:6)', 1, NbROI) + repmat(linspace(-.2, .2, NbROI), 6, 1);
    if dash
        X_pos = repmat((1:6)', 1, NbROI) + repmat(linspace(-.1, .3, NbROI), 6, 1);
    end

    l = errorbar( ...
                 X_pos, ...
                 ToPlot.profile(iRow, iColumn).MEAN(:, ROIs_to_plot), ...
                 ToPlot.profile(iRow, iColumn).SEM(:, ROIs_to_plot));

    l2 = plot( ...
              X_pos, ...
              ToPlot.profile(iRow, iColumn).MEAN(:, ROIs_to_plot));

    for iLine = 1:numel(l)
        set(l(iLine), 'color', ToPlot.line_colors(ROIs_to_plot(iLine), :));
        set(l2(iLine), 'color', ToPlot.line_colors(ROIs_to_plot(iLine), :), 'linewidth', 2);
        if dash
            set(l2(iLine), 'linestyle', '--');
        end
    end

end

function plot_betas(Data, ToPlot, fontsize, iCdt, iColumn, S_param)

    [ROIs_to_plot, NbROI] = find_rois(ToPlot.profile(iCdt, iColumn));

    Alpha = 0.05 / NbROI;

    Xpos = [1 3 6:2:14];
    Xpos = Xpos(1:NbROI);

    % plot zero line
    if ToPlot.Cst
        plot([-25 25], [0.5 0.5], '-k', 'LineWidth', .8);
    else
        plot([-25 25], [0 0], '-k', 'LineWidth', .8);
    end

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

        if ToPlot.CI_s_parameter

            % the more traditional 95% CI based on student distribution
            %         Lower = nanmean(Data(:,i))-1.96*nansem(Data(:,i))
            %         Upper = nanmean(Data(:,i))+1.96*nansem(Data(:,i))

            % based on bias-corrected and accelerated bootstrap confidence interval

            % using bias correction of effect size estimate (Hedges and Olkin)
            %         CI = bootci(10000,{@(x) Unbiased_ES(x), Data(:,i)},'alpha', Alpha, 'type','bca');
            %         Lower = CI(1);
            %         Upper = CI(2);

            % using mean as estimate of effect size
            CI = bootci(10000, {@(x) mean(x), Data(:, i)}, 'alpha', Alpha, 'type', 'bca');
            Lower = CI(1);
            Upper = CI(2);

        else
            Lower = nanmean(Data(:, i)) - nansem(Data(:, i));
            Upper = nanmean(Data(:, i)) + nansem(Data(:, i));
        end

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

    if ToPlot.plot_pvalue

        for iROI = 1:size(Data, 2)

            [~, P, ~] = run_t_perm_test(ToPlot, iCdt, ROIs_to_plot(iROI), S_param, Data(:, iROI));

            Sig = []; %#ok<NASGU>
            if P < 0.001
                Sig = sprintf('p<0.001 ');
            else
                Sig = sprintf('p=%.3f ', P);
            end

            t = text( ...
                     Xpos(iROI) - .8, ...
                     MAX, ...
                     sprintf(Sig));
            set(t, 'fontsize', fontsize - 2);

            if P < Alpha
                set(t, 'fontweight', 'bold', 'fontsize', fontsize - 1.5);
            end
        end

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

function du = Unbiased_ES(grp_data)
    % from DOI 10.1177/0013164404264850
    d = mean(grp_data) / std(grp_data);
    nu = length(grp_data) - 1;
    G = gamma(nu / 2) / (sqrt(nu / 2) * gamma((nu - 1) / 2));
    du = d * G;
end
