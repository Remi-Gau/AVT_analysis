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

    % compute S parameter betas
    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, true);
    for iColumn = 1:size(Data, 2)
        for iLine = 1:size(Data, 3)

            BetaHat{:, iColumn, iLine} = RunLaminarGlm(Data{:, iColumn, iLine}, DesignMatrix);

            GroupData{:, iColumn, iLine} = ComputeSubjectAverage( ...
                                                                 BetaHat{:, iColumn, iLine}, ...
                                                                 SubjectVec{:, iColumn, iLine});

        end
    end

    for iCondtion = 1:Opt.m

        PlotGroupProfile(Data, SubjectVec, Opt, iCondtion);

        %         PlotBetasLaminarGlm(Data, SubjectVec, Opt, iCondtion);

        %% Get min and max over subjects for this s parameter
        % TODO : - try to refactor and reuse the same approach as for P
        %        values.
        %        - make it possible to set min and max across conditions (columns of a figure)
        %         [ThisMin, ThisMax] = ComputeMinMax(Opt.PlotMinMaxType, ...
        %             BetaHat{:, iCondtion, iLine}(:, iParameter), ...
        %             SubjectVec, ...
        %             Opt);
        %         Max = max([Max, ThisMax]);
        %         Min = min([Min, ThisMin]);

        MinMax = [-5 5];

        DataToPlot = GroupData(:, iCondtion, :);

        PlotBetasLaminarGlm(DataToPlot, Opt, MinMax, 1, iCondtion);

        PlotBetasLaminarGlm(DataToPlot, Opt, MinMax, 2, iCondtion);

        if Opt.PlotQuadratic
            PlotBetasLaminarGlm(DataToPlot, Opt, MinMax, 3, iCondtion);
        end

    end

end

function Opt = CheckPlottingOptions(Opt, Data)

    Opt.Fontsize = 8;
    Opt.Visible = 'on';

    if ~isfield(Opt, 'LineColors')
        Opt.LineColors = RoiColours();
    end

    if ~isfield(Opt, 'PermutationTest')
        Opt.Ttest.PermutationTest.Do = false;
    end

    if ~isfield(Opt, 'PlotPValue')
        Opt.PlotPValue = true;
    end

    if contains(Opt.ErrorBarType, 'CI')
        Opt.ShadedErrorBar = false;
    end

    if size(Data, 3) > 1
        Opt.ShadedErrorBar = false;
        Opt.PlotSubjects = false;
    end

    % define subplot grid
    Opt.m = size(Data, 2);

    Opt.n = 3;
    if Opt.PlotQuadratic
        Opt.n = 4;
    end
    Opt.n = Opt.n + 1;

    switch Opt.m
        case 1
            Opt.FigDim = [50, 50, 600, 800];
        case 2
            Opt.FigDim = [50, 50, 1200, 800];
        case 3
            Opt.FigDim = [50, 50, 1800, 800];
    end

    if Opt.PlotQuadratic
        Opt.FigDim(4) = 1000;
    end

    if Opt.Ttest.PermutationTest.Do
        Opt = CreatePermutationList(Opt);
    end

end
