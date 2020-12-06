% (C) Copyright 2020 Remi Gau

function PlotBetasLaminarGlm(Data, SubjectVec, Opt, iCondtion)
    
    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, true);
    
    ParameterNames = {'Constant', 'Linear', 'Quadratic'};
    
    if Opt.PlotQuadratic
        NbParametersToPlot = 3;
    else
        NbParametersToPlot = 2;
    end
    
    for iParameter = 1:NbParametersToPlot
        
        ThisSubplot = GetSubplotIndex(iCondtion, iParameter, Opt);
        
        subplot(Opt.n, Opt.m, ThisSubplot);
        
        hold on;
        grid on;
        
        Min = 0;
        Max = 0;
        
        AllGroupBetas = [];
        
        % for each ROI or Condition depending on how the input data is formated
        for iLine = 1:size(Data, 3)
            
            BetaHat = RunLaminarGlm(Data{:, iCondtion, iLine}, DesignMatrix);
            
            GroupData = ComputeSubjectAverage( ...
                BetaHat, ...
                SubjectVec{:, iCondtion, iLine});
            
            % Store to compute p values and max min
            AllGroupBetas(:, iLine) = GroupData(:, iParameter); %#ok<*AGROW>
            
            %% Main plot
            ViolinPlot(GroupData, iParameter, Opt, iLine)
            
            %% Plot mean + dispersion
            PlotMeanAndDispersion(GroupData, Opt, iParameter, iLine);
            
            %% Get min and max over subjects for this s parameter
            % TODO : - try to refactor and reuse the same approach as for P
            %        values.
            %        - make it possible to set min and max across conditions (columns of a figure)
            [ThisMin, ThisMax] = ComputeMinMax(...
                {BetaHat(:, iParameter)}, ...
                SubjectVec, ...
                Opt);
            Max = max([Max, ThisMax]);
            Min = min([Min, ThisMin]);
            
        end
        
        %% plot zero line
        Baseline = [0, 0];
        if Opt.IsMvpa
            Baseline = [0.5, 0.5];
        end
        Xpos = ReturnXpositionViolinPlot();
        plot([0, max(Xpos) + 0.5], Baseline, '-k', 'LineWidth', 1);
        
        %% Tight fight with some vertical margin
        [Min, Max, Margin] = ComputeMargin(Min, Max, 3);
        
        axis([0, Xpos(numel(Opt.RoiNames)) + .5, Min, Max]);
        
        %% Labels
        set(gca, ...
            'tickdir', 'out', ...
            'xtick', Xpos - 0.25, ...
            'xticklabel', Opt.RoiNames, ...
            'xgrid', 'off', ...
            'ticklength', [0.01 0.01], ...
            'fontsize', Opt.Fontsize);
        
        YLabel = '\nS Param. est. [a u]';
        YLabel = [ParameterNames{iParameter}, YLabel];
        t = ylabel(sprintf(YLabel));
        set(t, ...
            'fontweight', 'bold', ...
            'fontsize', Opt.Fontsize);
        
        %% Compute p values and print them
        % offset values for oncoming stats: accuracy tested against null = 0.5
        if Opt.IsMvpa
            % Data = Data - .5;
        end
        
        [P, ~, ~] = ComputePValue(AllGroupBetas, Opt);
        
        PrintPValue(P, Xpos - 0.25, Max - Margin / 2, Opt);
        
    end
    
end

function  ThisSubplot = GetSubplotIndex(iCondtion, iParameter, Opt)
    %
    % returns subplot on which to draw the lainar profile depending on the
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
    
    ThisSubplot = SubplotTable(iParameter, Opt.m, iCondtion);
    
end

function ViolinPlot(GroupData, iParameter, Opt, iLine)
    
    DIST_WIDTH = 0.5;
    SHOW_MEAN_MEDIAN = 0;
    GLOBAL_NORM = 2;
    
    MARKER = 'o';
    MARKER_SIZE = 5;
    MARKER_EDGE_COLOR = 'k';
    MARKER_FACE_COLOR = 'w';
    
    LINE_WIDTH = 1;
    BIN_WIDTH = 0.5;
    SPREAD_WIDTH = 0.5;
    
    Color = Opt.LineColors(iLine, :);
    Xpos = ReturnXpositionViolinPlot();
    
    distributionPlot( ...
        GroupData(:, iParameter), ...
        'xValues', Xpos(iLine), ...
        'color', Color, ...
        'distWidth', DIST_WIDTH, ...
        'showMM', SHOW_MEAN_MEDIAN, ...
        'globalNorm', GLOBAL_NORM);
    
    h = plotSpread( ...
        GroupData(:, iParameter), ...
        'xValues', Xpos(iLine), ...
        'distributionMarkers', {MARKER}, ...
        'binWidth', BIN_WIDTH, ...
        'spreadWidth', SPREAD_WIDTH);
    set(h{1}, ...
        'MarkerSize', MARKER_SIZE, ...
        'MarkerEdgeColor', MARKER_EDGE_COLOR, ...
        'MarkerFaceColor', MARKER_FACE_COLOR, ...
        'LineWidth', LINE_WIDTH);
    
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

function PlotMeanAndDispersion(GroupData, Opt, iParameter, iLine)
    %
    % Plots a thin error bar and a thick line across data points
    %
    
    LINE_WIDTH = 1;
    MARKER = 'o';
    MARKER_SIZE = 5;
    
    Color = Opt.LineColors(iLine, :);
    Xpos = ReturnXpositionViolinPlot();
    
    GroupMean =  mean(GroupData(:, iParameter));
    [LowerError, UpperError] = ComputeDispersionIndex(GroupData(:, iParameter), Opt);
    
    l = errorbar( ...
        Xpos(iLine) - 0.5, ...
        GroupMean, ...
        LowerError, ...
        UpperError);
    
    set(l, ...
        'LineWidth', LINE_WIDTH, ...
        'Color', Color);
    
    l = plot( ...
        Xpos(iLine) - 0.5, ...
        GroupMean);
    
    set(l, ...
        'Marker', MARKER, ...
        'MarkerSize', MARKER_SIZE, ...
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
            set(t, 'fontsize', Opt.Fontsize);
            
            if P(iP) < Opt.Alpha
                set(t, ...
                    'color', 'k', ...
                    'fontweight', 'bold', ...
                    'fontsize', Opt.Fontsize + 0.5);
            end
            
        end
        
    end
end


