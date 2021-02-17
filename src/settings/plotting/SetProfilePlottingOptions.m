% (C) Copyright 2021 Remi Gau

function Opt = SetProfilePlottingOptions(Opt)

    [NbLayers] = GetPlottingDefaults();

    Opt.PlotQuadratic = false;

    Opt.ErrorBarType = 'SEM';

    Opt.Alpha = 0.05 / 4;
    Opt.PlotPValue = true;
    Opt.PermutationTest.Do = true;
    Opt.PermutationTest.Plot = false;

    Opt.PerformDeconvolution = true;

    Opt.ShadedErrorBar = false;

    Opt.NbLayers = NbLayers;

    for i = 1:size(Opt.Specific, 2)
        if ~isfield(Opt.Specific{1, i}, 'PlotMinMaxType') || ...
                isempty(Opt.Specific{1, i}.PlotMinMaxType)
            Opt.Specific{1, i}.PlotMinMaxType = 'group'; % all group groupallcolumns
        end
        Opt.Specific{1, i}.IsMvpa = false;
        Opt.Specific{1, i}.Ttest.SideOfTtest = 'both';
        Opt.Specific{1, i}.PlotSubjects = true;
    end

    if isfield(Opt, 'IsDifferencePlot') && Opt.IsDifferencePlot
        Opt.m = 2;
        Opt.n = 10;

        Opt.Specific{1, 1}.ProfileSubplot = 1:6;
        Opt.Specific{1, 1}.BetaSubplot = {[15 17]; [19 21]; [23 25]};

        Opt.Specific{1, 2}.ProfileSubplot = 7:12;
        Opt.Specific{1, 2}.BetaSubplot = {[16 18]; [20 22]; [24 26]};
        Opt.Specific{1, 2}.LineColors = [127 127 127] / 256;

        Opt.Specific{1, 2}.PlotMinMaxType = 'all';
    end

end
