% (C) Copyright 2020 Remi Gau

function  PlotGroupProfile(Data, SubjectVec, Opt, iCondtion)

    ThisSubplot = GetSubplotIndices(iCondtion, Opt);

    subplot(Opt.n, Opt.m, ThisSubplot);
    PlotRectangle(Opt, true);

    subplot(Opt.n, Opt.m, ThisSubplot);

    hold on;
    grid on;

    for iLine = 1:size(Data, 3)

        GroupData = ComputeSubjectAverage( ...
                                          Data{:, iCondtion, iLine}, ...
                                          SubjectVec{:, iCondtion, iLine});

        GroupMean =  mean(GroupData);
        [LowerError, UpperError] = ComputeDispersionIndex(GroupData, Opt);

        PlotProfileSubjects(GroupData, Opt);

        xOffset = (iLine - 1) * 0.1;
        PlotMainProfile(GroupMean, LowerError, UpperError, Opt, xOffset, iLine);

    end

    %% Baseline
    Baseline = [0, 0];
    if Opt.IsMvpa
        Baseline = [0.5, 0.5];
    end
    plot([0, Opt.NbLayers + 0.5], Baseline, '-k', 'LineWidth', 1);

    %% Set tighet axes with margin
    [Min, Max] = ComputeMinMax(Data, SubjectVec, Opt, iCondtion);
    [Min, Max] = ComputeMargin(Min, Max);

    axis([0.5, Opt.NbLayers + .5, Min, Max]);

    %% Labels and titles
    set(gca, ...
        'tickdir', 'out', ...
        'xtick', [0 Opt.NbLayers], ...
        'xticklabel', ' ', ...
        'ticklength', [0.01 0.1], ...
        'xgrid', 'off', ...
        'fontsize', Opt.Fontsize);

    XLabel = 'Cortical depth';
    t = xlabel(XLabel);
    set(t, ...
        'fontweight', 'bold', ...
        'fontsize', Opt.Fontsize);

    YLabel = 'B Param. est. [a u]';
    if Opt.IsMvpa
        YLabel = 'Decoding accuracy';
    end
    t = ylabel(YLabel);
    set(t, ...
        'fontweight', 'bold', ...
        'fontsize', Opt.Fontsize);

    Title = Opt.Titles{1, iCondtion};
    t = title(Title);
    set(t, 'fontsize', Opt.Fontsize + 2);

end

function PlotMainProfile(GroupMean, LowerError, UpperError, Opt, xOffset, iLine)
    %
    % Plots the laminar profile for BOLD or MVPA
    %

    if nargin < 6 || isempty(iLine)
        LINE_COLOR = 'k';
    else
        LINE_COLOR = Opt.LineColors(iLine, :);
    end

    LINE_WIDTH = 2;
    MARKER = 'o';
    MARKER_SIZE = 4;
    
    LINE_STYLE = '-';
    MARKER_FACE_COLOR = LINE_COLOR;

    xPosition = (1:Opt.NbLayers) + xOffset;

    if Opt.ShadedErrorBar

        TRANSPARENT = true;

        shadedErrorBar( ...
                       xPosition, ...
                       GroupMean, ...
                       [LowerError; UpperError], ...
                       'lineProps', { ...
                                     'Marker', MARKER, ...
                                     'MarkerSize', MARKER_SIZE, ...
                                     'MarkerFaceColor', MARKER_FACE_COLOR, ...
                                     'LineStyle', LINE_STYLE, ...
                                     'LineWidth', LINE_WIDTH, ...
                                     'Color', LINE_COLOR}, ...
                       'transparent', TRANSPARENT);

    else

        % Plots a thin error bar and a thick line across data points
        l = errorbar( ...
                     xPosition, ...
                     GroupMean, ...
                     LowerError, ...
                     UpperError);

        set(l, ...
            'LineStyle', LINE_STYLE, ...
            'Color', LINE_COLOR);

        l = plot( ...
                 xPosition, ...
                 GroupMean);

        set(l, ...
            'Marker', MARKER, ...
            'MarkerSize', MARKER_SIZE, ...
            'MarkerFaceColor', MARKER_FACE_COLOR, ...
            'LineStyle', LINE_STYLE, ...
            'LineWidth', LINE_WIDTH, ...
            'Color', LINE_COLOR);

    end
end

function PlotProfileSubjects(GroupMean, Opt)

    if Opt.PlotSubjects

        % TODO
        % plot each subject with its own color
        % COLOR_SUBJECTS = SubjectColours();

        for SubjInd = 1:size(GroupMean, 1)
            plot( ...
                 1:Opt.NbLayers, ...
                 GroupMean(SubjInd, :), '-', ...
                 'LineWidth', 1, ...
                 'Color', [0.7, 0.7, 0.7]);
        end

    end

end

function ThisSubplot = GetSubplotIndices(iCondtion, Opt)
    %
    % returns subplot on which to draw the lainar profile depending on the
    % number of columns in the figure
    %

    switch Opt.m

        case 1
            ThisSubplot = 1:2;

        case 2

            switch iCondtion
                case 1
                    ThisSubplot = [1 3];

                case 2
                    ThisSubplot = [2 4];
            end

        case 3

            switch iCondtion
                case 1
                    ThisSubplot = [1 4];

                case 2
                    ThisSubplot = [2 5];

                case 3
                    ThisSubplot = [3 6];
            end

    end

end
