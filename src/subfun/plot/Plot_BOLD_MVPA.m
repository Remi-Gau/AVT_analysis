% (C) Copyright 2020 Remi Gau
function Plot_BOLD_MVPA(DATA)

    if nargin < 1
        error('No data to plot');
        return  %#ok<UNRCH>
    end

    Fontsize = 12;

    Transparent = 1;

    % Color for Subjects

    %%
    Mean = DATA.Data.MEAN;
    ErrorBar = DATA.Data.SEM;

    NbLayers = size(Mean, 1);
    NbCdts = size(Mean, 2);

    SubplotGroup = DATA.SubplotGroup;
    [m, n] = deal(DATA.mn(1), DATA.mn(2));

    SubPlotOrder = DATA.SubPlotOrder;
    Legend = DATA.Legend;

    if DATA.PlotSub
        Subjects = DATA.Data.grp;
        NbSubjects = size(Subjects, 3);
    end

    Beta = DATA.Data.Beta.DATA;

    WithQuad = DATA.WithQuad;
    Scatter = linspace(0, .4, NbSubjects);

    if DATA.PlotSub
        MAX = max(Subjects(:));
        MIN = min(Subjects(:));
    else
        MAX = max(Mean(:) + ErrorBar(:));
        MIN = min(Mean(:) + ErrorBar(:));
    end

    XYs = DATA.XYs;

    for iCdt = 1:NbCdts
        %% Plot main data
        subplot(m, n, SubplotGroup(iCdt, :));
        PlotRectangle(NbLayers, Fontsize);
        subplot(m, n, SubplotGroup(iCdt, :));

        hold on;
        grid on;

        shadedErrorBar(1:NbLayers, flipud(Mean(:, SubPlotOrder(iCdt))), flipud(ErrorBar(:, SubPlotOrder(iCdt))), ...
                       {'Marker', '.', 'MarkerSize', 25, 'LineWidth', 3, 'Color', 'b'}, Transparent);
        for SubjInd = 1:NbSubjects
            %         plot(1:NbLayers, flipud(Subjects(:,SubPlotOrder(iCdt),SubjInd)), '-', ...
            %             'LineWidth', 1.5, 'Color', COLOR_Subject(SubjInd,:));
            plot(1:NbLayers, flipud(Subjects(:, SubPlotOrder(iCdt), SubjInd)), '-', ...
                 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);
        end
        shadedErrorBar(1:NbLayers, flipud(Mean(:, SubPlotOrder(iCdt))), flipud(ErrorBar(:, SubPlotOrder(iCdt))), ...
                       {'Marker', '.', 'MarkerSize', 25, 'LineWidth', 3, 'Color', 'b'}, Transparent);

        if DATA.MVPA
            plot([1 NbLayers], [0.5 0.5], '--k', 'LineWidth', 1);
        else
            plot([1 NbLayers], [0 0], '-k', 'LineWidth', 1);
        end

        set(gca, 'tickdir', 'out', 'xtick', 1:NbLayers, ...
            'xticklabel', ' ', 'ticklength', [0.01 0.01], ...
            'xgrid', 'off', 'fontsize', Fontsize);

        %     t=xlabel('Cortical depth');
        %     set(t,'fontsize',Fontsize);

        t = ylabel(Legend{SubPlotOrder(iCdt)}{1});
        set(t, 'fontsize', Fontsize + 2);

        t = title(Legend{SubPlotOrder(iCdt)}{2});
        set(t, 'fontsize', Fontsize);

        axis([0.5 NbLayers + .5 MIN MAX]);

        %% Inset with betas
        tmp = squeeze(Beta(:, SubPlotOrder(iCdt), :));
        BetaMax = max(max(abs(Beta), [], 3), [], 2);

        for i = 1:size(tmp, 1)

            Lim = round(BetaMax(i) + .1 * BetaMax(i), 2);

            XY = XYs(iCdt, :);
            axes('Position', [XY(1) + 0.13 * (i - 1) XY(2) .075 .08]);

            box off;
            hold on;

            [H(i), P(i)] = ttest(tmp(i, :), 0, 'alpha', 0.05);

            %         for SubjInd=1:size(tmp,2)
            %             plot(1.2+Scatter(SubjInd), tmp(i,SubjInd), ...
            %                 'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(SubjInd,:), ...
            %                 'MarkerFaceColor', COLOR_Subject(SubjInd,:), 'MarkerSize', 15)
            %         end

            distributionPlot({tmp(i, :)}, 'xValues', 1.3, 'color', [0.8 0.8 0.8], ...
                             'distWidth', 0.4, 'showMM', 0, ...
                             'globalNorm', 2);

            h = plotSpread(tmp(i, :), 'distributionIdx', ones(size(tmp(i, :))), ...
                           'distributionMarkers', {'o'}, 'distributionColors', {'w'}, ...
                           'xValues', 1.3, 'binWidth', .5, 'spreadWidth', 0.5);
            if ~isnan(h{1})
                set(h{1}, 'MarkerSize', 5, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1);
            end

            plot([0 1.55], [0 0], ':k', 'LineWidth', .5);

            h = errorbar(1, nanmean(tmp(i, :), 2), nansem(tmp(i, :), 2), '.k');

            Sig = [];
            if P(i) < 0.001
                Sig = sprintf('ES=%.2f \np<0.001 ', ...
                              abs(nanmean(tmp(i, :)) / nanstd(tmp(i, :))));
            else
                Sig = sprintf('ES=%.2f \np=%.3f ', ...
                              abs(nanmean(tmp(i, :)) / nanstd(tmp(i, :))), P(i));
            end

            %         t = text(.8,Lim+Lim*50/100,sprintf(Sig));
            t = text(1.6, 0, sprintf(Sig));
            set(t, 'fontsize', Fontsize - 4.5);

            if H(i) == 1
                set(t, 'color', 'r');
            end

            clear Sig;

            switch i
                case 1
                    xTickLabel = 'C';
                case 2
                    xTickLabel = 'L';
                case 3
                    xTickLabel = 'Q';
            end

            set(gca, 'tickdir', 'in', 'xtick', 1.3, 'xticklabel', xTickLabel, ...
                'ytick', linspace(Lim * -1, Lim, 5), 'yticklabel', linspace(Lim * -1, Lim, 5), ...
                'ticklength', [0.03 0.03], 'fontsize', Fontsize - 4);
            if i == 1
                %             t=ylabel('betas');
                %             set(t,'fontsize',Fontsize-3);
            end

            axis([0.9 1.8 Lim * -1 Lim]);

        end

    end

end
