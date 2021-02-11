% (C) Copyright 2020 Remi Gau

function PlotBetasLaminarGlm(Opt, iParameter, iColumn)

    if nargin < 3 || isempty(iColumn)
        iColumn = 1;
    end

    ParameterNames = {'Constant', 'Linear', 'Quadratic'};

    ThisSubplot = GetSubplotIndex(Opt, iColumn, iParameter);

    subplot(Opt.n, Opt.m, ThisSubplot);

    hold on;
    grid on;

    %% plot zero line
    Baseline = [0, 0];
    IsMvpa = Opt.Specific{1, iColumn}.IsMvpa;
    if IsMvpa
        Baseline = [0.5, 0.5];
    end
    Xpos = ReturnXpositionViolinPlot();
    plot([0, max(Xpos) + 0.5], Baseline, '-k', 'LineWidth', 1);

    RoiVec = Opt.Specific{1, iColumn}.Group.RoiVec;
    ConditionVec = Opt.Specific{1, iColumn}.Group.ConditionVec;

    RoiList = unique(RoiVec);
    CdtList = unique(ConditionVec);

    AllGroupBetas = [];
    iLine = 1;

    for iRoi = 1:numel(RoiList)

        for iCdt = 1:numel(CdtList)

            Criteria = {
                        RoiVec, RoiList(iRoi); ...
                        ConditionVec, CdtList(iCdt)};
            RowsToSelect = ReturnRowsToSelect(Criteria);

            DataToPlot = Opt.Specific{1, iColumn}.Group.Beta.Data(RowsToSelect, iParameter);

            % Store to compute p values and max min
            AllGroupBetas(:, iLine) = DataToPlot; %#ok<*AGROW>

            %% Main plot
            ViolinPlot(DataToPlot, Opt, iColumn, iLine);

            %% Plot mean + dispersion
            PlotMeanAndDispersion(DataToPlot, Opt, iColumn, iLine);

            iLine = iLine + 1;

        end
    end

    %% Tight fit with some vertical margin
    ViolinPlotParameters = GetViolinPlotParameters();
    [Min, Max, Margin] = ComputeMargin(Opt.Specific{1, iColumn}.Group.Beta.Min, ...
                                       Opt.Specific{1, iColumn}.Group.Beta.Max, ...
                                       ViolinPlotParameters.Margin);

    axis([0, Xpos(numel(Opt.Specific{1, iColumn}.XLabel)) + .5, Min, Max]);

    %% Labels
    XLabel = '';
    if iParameter > 1
        XLabel = Opt.Specific{1, iColumn}.XLabel;
    end
    set(gca, ...
        'tickdir', 'out', ...
        'xtick', Xpos - 0.25, ...
        'xticklabel', XLabel, ...
        'xgrid', 'off', ...
        'ygrid', 'off', ...
        'ticklength', [0.01 0.01], ...
        'fontsize', Opt.Fontsize + 4);

    if iColumn == 1
        YLabel = '\nS Param. est. [a u]';
        YLabel = [ParameterNames{iParameter}, YLabel];
        t = ylabel(sprintf(YLabel));
        set(t, ...
            'fontweight', 'bold', ...
            'fontsize', Opt.Fontsize);
    end

    %% Compute p values and print them
    % offset values for oncoming stats: accuracy tested against null = 0.5
    if IsMvpa
        % Data = Data - .5;
    end

    [P, ~] = ComputePValue(AllGroupBetas, Opt, Opt.Specific{1, iColumn}.Ttest);

    PrintPValue(P, Xpos - 0.25, Max + Margin / 6, Opt);

end

function  ThisSubplot = GetSubplotIndex(Opt, iColumn, iParameter)
    %
    % returns subplot on which to draw the laminar profile depending on the
    % number of columns in the figure
    %
    %
    % For for the first column of subplot in the figure
    % Each row is for a S parameters (Cst, Lin, Quad)
    % The index of columns in the array indicates the total number of Columns in
    % the figure
    %
    % When plotting a figure with 3 colmuns and we want to plot the constant of
    % the second column fo subplots, we take the element SubplotTable(1, 3 , 2)
    %

    if isfield(Opt.Specific{1, iColumn}, 'BetaSubplot')
        ThisSubplot = Opt.Specific{1, iColumn}.BetaSubplot{iParameter};
        return
    end

    SubplotTable(:, :, 1) = [ ...
                             3, 5, 7
                             4, 7, 10
                             5, 9, 13];

    % For for the second column  of subplot in the figure
    SubplotTable(:, :, 2) = SubplotTable(:, :, 1) + 1;
    SubplotTable(:, 1, 2) = nan(3, 1);

    % For for the third column  of subplot in the figure
    SubplotTable(:, :, 3) = SubplotTable(:, :, 2) + 1;
    SubplotTable(:, 2, 3) = nan(3, 1);

    ThisSubplot = SubplotTable(iParameter, Opt.m, iColumn);

end

function ViolinPlot(GroupData, Opt, iColumn, iLine)

    ViolinPlotParameters = GetViolinPlotParameters();

    Xpos = ReturnXpositionViolinPlot();

    distributionPlot( ...
                     GroupData, ...
                     'xValues', Xpos(iLine), ...
                     'color', Opt.Specific{1, iColumn}.LineColors(iLine, :), ...
                     'distWidth', ViolinPlotParameters.DistWidth, ...
                     'showMM', ViolinPlotParameters.ShowMeanMedian, ...
                     'globalNorm', ViolinPlotParameters.GlobalNorm);

    h = plotSpread( ...
                   GroupData, ...
                   'xValues', Xpos(iLine), ...
                   'distributionMarkers', {ViolinPlotParameters.Marker}, ...
                   'binWidth', ViolinPlotParameters.BinWidth, ...
                   'spreadWidth', ViolinPlotParameters.SpreadWidth);
    set(h{1}, ...
        'MarkerSize', ViolinPlotParameters.MarkerSize, ...
        'MarkerEdgeColor', ViolinPlotParameters.MarkerEdgeColor, ...
        'MarkerFaceColor', ViolinPlotParameters.MarkerFaceColor, ...
        'LineWidth', ViolinPlotParameters.LineWidth);

    %  TODO
    %  Plot each subject with its color
    %
    %  COLOR_Subject = ColorSubject();
    %  scatter = linspace(-0.4, 0.4, size(tmp, 1));
    %  for isubj = 1:size(tmp, 1)
    %   plot(...
    %         Xpos(iLine) + scatter(isubj), ...
    %         tmp_cell{iLine}(isubj), ...
    %         'o', ...
    %         'MarkerSize', 5, ...
    %         'MarkerEdgeColor', COLOR_Subject(isubj, :), ...
    %         'MarkerFaceColor', COLOR_Subject(isubj, :));
    %  end

end

function PlotMeanAndDispersion(GroupData, Opt, iColumn, iLine)
    %
    % Plots a thin error bar and a thick line across data points
    %

    [~, MeanDispersion] = GetViolinPlotParameters();

    Color = Opt.Specific{1, iColumn}.LineColors(iLine, :);
    Xpos = ReturnXpositionViolinPlot();

    GroupMean =  mean(GroupData);
    [LowerError, UpperError] = ComputeDispersionIndex(GroupData, Opt);

    l = errorbar( ...
                 Xpos(iLine) - 0.5, ...
                 GroupMean, ...
                 LowerError, ...
                 UpperError);

    set(l, ...
        'LineWidth', MeanDispersion.LineWidth, ...
        'Color', Color);

    l = plot( ...
             Xpos(iLine) - 0.5, ...
             GroupMean);

    set(l, ...
        'Marker', MeanDispersion.Marker, ...
        'MarkerSize', MeanDispersion.MarkerSize, ...
        'MarkerFaceColor', Color, ...
        'Color', Color);

end

function PrintPValue(P, Xpos, Ypos, Opt)

    if Opt.PlotPValue

        for iP = 1:numel(P)

            Sig = [];
            if P(iP) < 0.001
                Sig = sprintf('p<0.001 ');
            else
                Sig = sprintf('p=%.3f ', P(iP));
            end

            t = text( ...
                     Xpos(iP) - .2, ...
                     Ypos, ...
                     sprintf(Sig));
            set(t, 'fontsize', Opt.Fontsize - 2);

            if P(iP) < Opt.Alpha
                set(t, ...
                    'color', 'k', ...
                    'fontweight', 'bold', ...
                    'fontsize', Opt.Fontsize - 2);
            end

        end

    end
end
