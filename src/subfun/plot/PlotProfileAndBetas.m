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

    for iCondtion = 1:Opt.m
        PlotGroupProfile(Data, SubjectVec, Opt, iCondtion);
        PlotBetasLaminarGlm(Data, SubjectVec, Opt, iCondtion);
    end

end

function Opt = CheckPlottingOptions(Opt, Data)

    Opt.Fontsize = 8;
    Opt.Visible = 'on';

    if ~isfield(Opt, 'LineColors')
        Opt.LineColors = RoiColours();
    end

    if ~isfield(Opt, 'PermutationTest')
        Opt.PermutationTest.Do = false;
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

    if Opt.PermutationTest.Do
        Opt = CreatePermutationList(Opt);
    end

end
