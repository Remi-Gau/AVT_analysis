% (C) Copyright 2021 Remi Gau

function Opt = SetProfilePlottingOptions(Opt)

    [NbLayers] = GetPlottingDefaults();

    Opt.PlotQuadratic = false;

    Opt.ErrorBarType = 'SEM';

    Opt.Alpha = 0.05 / 4;
    Opt.PlotPValue = true;
    Opt.PermutationTest.Do = true;
    Opt.PermutationTest.Plot = false;

    Opt.PlotSubjects = true;
    Opt.ShadedErrorBar = false;

    Opt.NbLayers = NbLayers;

    for i = 1:size(Opt.Specific, 2)
        if ~isfield(Opt.Specific{1, i}, 'PlotMinMaxType') || ...
                isempty(Opt.Specific{1, i}.PlotMinMaxType)
            Opt.Specific{1, i}.PlotMinMaxType = 'group'; % all group groupallcolumns
        end
        Opt.Specific{1, i}.IsMvpa = false;
        Opt.Specific{1, i}.Ttest.SideOfTtest = 'both';
    end

end
