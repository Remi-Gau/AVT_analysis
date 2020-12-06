% (C) Copyright 2020 Remi Gau

function PlotProfileAndBetas(Data, SubjectVec, Opt)
    
    if ~iscell(Data)
        tmp{:, :, 1} = Data;
        Data = tmp;
    end
    
    if ~iscell(SubjectVec)
        tmp{:, :, 1} = SubjectVec;
        SubjectVec = tmp;
    end
    
    Opt = CheckPlottingOptions(Opt, Data);

    figure('Name', 'test', ...
        'Position', Opt.FigDim, ...
        'Color', [1 1 1], ...
        'Visible', Opt.Visible);
    
    SetFigureDefaults(Opt);
    
    % define subplot grid
    Opt.m = size(Data, 2);
    
    Opt.n = 3;
    if Opt.PlotQuadratic
        Opt.n = 4;
    end
    Opt.n = Opt.n + 1;
    
    PlotGroupProfile(Data, SubjectVec, Opt);
    
    %% Inset with betas
    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, true);
    %     betaHat = RunLaminarGlm(Data, DesignMatrix);
    %     PlotBetasLaminarGlm(Data, Opt)
    
end

function Opt = CheckPlottingOptions(Opt, Data)
    
    Opt.Fontsize = 8;
    Opt.Visible = 'on';
    
    if contains(Opt.ErrorBarType, 'CI')
        Opt.ShadedErrorBar = false;
    end
    
    if size(Data, 3) > 1
        Opt.ShadedErrorBar = false;
        Opt.PlotSubjects = false;
    end
end

function PlotGroupProfile(Data, SubjectVec, Opt)
    
    subplot(Opt.n, Opt.m, 1:2);
    PlotRectangle(Opt, true);
    
    subplot(Opt.n, Opt.m, 1:2);
    
    hold on;
    grid on;
    
    for iLine = 1:size(Data, 3)
        
        GroupData = ComputeSubjectAverage(Data{:, :, iLine}, SubjectVec{:, :, iLine});
        
        GroupMean =  mean(GroupData);
        [LowerError, UpperError] = ComputeDispersionIndex(GroupData, Opt);
        
        PlotProfileSubjects(GroupData, Opt);
        
        xOffset = (iLine - 1) * 0.1;
        PlotMainProfile(GroupMean, LowerError, UpperError, Opt, xOffset);
        
    end
    
    baseline = [0, 0];
    if Opt.IsMvpa
        baseline = [0.5, 0.5];
    end
    plot([0, Opt.NbLayers + 0.5], baseline, '-k', 'LineWidth', 1);
    
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
    
    Title = Opt.Titles;
    t = title(Title);
    set(t, 'fontsize', Opt.Fontsize + 2);
    
    [Min, Max] = ComputeMinMax(Data, SubjectVec, Opt);
    Range = (Max - Min);
    Max = Max + (Range * 1.1  - Range) / 2;
    Min = Min - (Range * 1.1  - Range) / 2;
    
    axis([0.5, Opt.NbLayers + .5, Min, Max]);
    
end

function PlotMainProfile(GroupMean, LowerError, UpperError, Opt, xOffset)
    
    LineColor = 'b';
    LineStyle = '-';
    LineWidth = 3;
    
    Marker = 'o';
    MarkerFaceColor = LineColor;
    MarkerSize = 5;
    
    xPosition = (1:Opt.NbLayers) + xOffset;
    
    if Opt.ShadedErrorBar
        
        TRANSPARENT = true;
        
        shadedErrorBar( ...
            xPosition, ...
            GroupMean, ...
            [LowerError; UpperError], ...
            'lineProps', { ...
            'Marker', Marker, ...
            'MarkerSize', MarkerSize, ...
            'MarkerFaceColor', MarkerFaceColor, ...
            'LineStyle', LineStyle, ...
            'LineWidth', LineWidth, ...
            'Color', LineColor}, ...
            'transparent', TRANSPARENT);
        
    else
        
        l = errorbar( ...
            xPosition, ...
            GroupMean, ...
            LowerError, ...
            UpperError);
        
        set(l, ...
            'LineStyle', LineStyle, ...
            'Color', LineColor);
        
        l = plot(...
            xPosition, ...
            GroupMean);
        
        set(l, ...
            'Marker', Marker, ...
            'MarkerSize', MarkerSize, ...
            'MarkerFaceColor', MarkerFaceColor, ...
            'LineStyle', LineStyle, ...
            'LineWidth', LineWidth, ...
            'Color', LineColor);
        
    end
end

function PlotProfileSubjects(GroupMean, Opt)
    
    if Opt.PlotSubjects
        
        COLOR_SUBJECTS = SubjectColours();
        
        for SubjInd = 1:size(GroupMean, 1)
            plot( ...
                1:Opt.NbLayers, ...
                GroupMean(SubjInd, :), '-', ...
                'LineWidth', 1, ...
                'Color', [0.7, 0.7, 0.7]);
        end
        
    end
    
end