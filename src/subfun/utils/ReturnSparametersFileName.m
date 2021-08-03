% (C) Copyright 2021 Remi Gau

function Filename = ReturnSparametersFileName(ConditionName)

    Opt = SetDefaults();

    Filename = ['Group-Sparameters', ConditionName, ...
                '_average-', Opt.AverageType, ...
                '_nbLayers-', num2str(Opt.NbLayers), ...
                '_deconvolved-0'];

    if Opt.PerformDeconvolution
        Filename(end) = '1';
    end

end
