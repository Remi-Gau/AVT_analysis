% (C) Copyright 2020 Remi Gau

function PlotProfileAndBetas(Data, SubjectVec, Opt)

    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, true);

    GroupData = ComputeSubjectAverage(Data, SubjectVec);
    betaHat = RunLaminarGlm(Data, DesignMatrix);

    figure('Name', 'test', ...
           'Position', Opt.FigDim, ...
           'Color', [1 1 1], ...
           'Visible', Opt.Visible);

    SetFigureDefaults(Opt);

    % define subplot grid
    Opt.m = 1;

    Opt.n = 3;
    if Opt.PlotQuadratic
        Opt.n = 4;
    end
    Opt.n = Opt.n + 1;

    PlotGroupProfile(GroupData, Opt)

    %% Inset with betas
    
    %         PlotBetasLaminarGlm(Data, Opt)

end

function PlotGroupProfile(GroupData, Opt)

    subplot(Opt.n, Opt.m, 1:2);
    PlotRectangle(Opt, true);

    subplot(Opt.n, Opt.m, 1:2);

    hold on;
    grid on;

    GroupMean =  mean(GroupData);
    [LowerError, UpperError] = ReturnDispersionIndex(GroupData, Opt);

    PlotProfileSubjects(GroupData, Opt);
    PlotMainProfile(GroupMean, LowerError, UpperError, Opt);
    
    baseline = [0, 0];
    if Opt.IsMvpa
        baseline = [0.5, 0.5];
    end
    plot([0, Opt.NbLayers+0.5], baseline, '-k', 'LineWidth', 1);

    set(gca, ...
        'tickdir', 'out', ...
        'xtick', [0 Opt.NbLayers], ...
        'xticklabel', ' ', ...
        'ticklength', [0.01 0.1], ...
        'xgrid', 'off', ...
        'fontsize', Opt.Fontsize);

    XLabel = 'Cortical depth';
    t = xlabel(XLabel);
    set(t, 'fontsize', Opt.Fontsize);

    YLabel = 'B Param. est. [a u]';
    if Opt.IsMvpa
        YLabel = 'Decoding accuracy';
    end
    t = ylabel(YLabel);
    set(t, 'fontsize', Opt.Fontsize);

    Title = 'ROI name - Condition Name';
    t = title(Title);
    set(t, 'fontsize', Opt.Fontsize + 2);

    [MIN, MAX] = GetMinMax(GroupData, Opt);

    axis([0.5, Opt.NbLayers + .5, MIN, MAX]);

end

function [DispersionIndexLower, DispersionIndexUpper] = ReturnDispersionIndex(Data, Opt)

    DispersionIndex = std(Data);

    switch Opt.ErrorBar
        case 'SEM'
            DispersionIndex = nansem(Data);

        case 'CI'
            % the more traditional 95% CI based on student distribution
            %  CI(1) = nanmean(Data(:,i))-1.96*nansem(Data(:,i))
            %  CI(2) = nanmean(Data(:,i))+1.96*nansem(Data(:,i))

            % Accelerated bootstrap confidence interval
            % using mean as estimate of effect size
            CI = bootci(10000, {@(x) mean(x), Data}, ...
                        'alpha', Opt.Alpha, ...
                        'type', 'bca');

            DispersionIndex = CI;

        case 'CI-BC'

            % Accelerated bootstrap confidence interval
            % using bias correction of effect size estimate (Hedges and Olkin)
            CI = bootci(10000, {@(x) UnbiasedEffectSize(x), Data}, ...
                        'alpha', Opt.Alpha, ...
                        'type', 'bca');

            DispersionIndex = CI;

        otherwise
            DispersionIndex = std(Data);

    end
    
    
    if size(DispersionIndex, 1) == 1
        DispersionIndexUpper = DispersionIndex;
        DispersionIndexLower = DispersionIndex;
    elseif size(DispersionIndex, 1) == 2
        DispersionIndexUpper = DispersionIndex(2, :) - mean(Data);
        DispersionIndexLower = DispersionIndex(1, :) - mean(Data);
    end

end

function du = UnbiasedEffectSize(Data)
    % using bias correction of effect size estimate (Hedges and Olkin)
    % from DOI 10.1177/0013164404264850
    d = mean(Data) / std(Data);
    nu = length(Data) - 1;
    G = gamma(nu / 2) / (sqrt(nu / 2) * gamma((nu - 1) / 2));
    du = d * G;
end

function PlotMainProfile(GroupMean, LowerError, UpperError, Opt)

    LineColor = 'b';
    LineStyle = '-';
    LineWidth = 3;

    Marker = 'o';
    MarkerFaceColor = LineColor;
    MarkerSize = 5;

    if Opt.ShadedErrorBar

        TRANSPARENT = true;

        shadedErrorBar( ...
                       1:Opt.NbLayers, ...
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
                     1:Opt.NbLayers, ...
                     GroupMean, ...
                     LowerError, ...
                     UpperError);
                 
        set(l, ...
            'LineStyle', LineStyle, ...
            'Color', LineColor);                 
                 
        l = plot(                     1:Opt.NbLayers, ...
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

function [MIN, MAX] = GetMinMax(Data, Opt)

    GroupMean =  mean(Data);
    [LowerError, UpperError] = ReturnDispersionIndex(Data, Opt);
    
    MAX = max(GroupMean(:) + UpperError(:));
    MIN = min(GroupMean(:) - LowerError(:));
    
    if Opt.PlotSubjects
        MAX = max(Data(:));
        MIN = min(Data(:));
    end

    if MIN > 0
        MIN = 0;
    end

    if MAX < 0
        MAX = 0;
    end

    %                     MIN = ax(3) - 0.02;
    %                 MAX = ax(4) + 0.02;

end
