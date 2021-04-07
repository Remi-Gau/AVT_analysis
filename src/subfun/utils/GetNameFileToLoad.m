% (C) Copyright 2020 Remi Gau

function Filename = GetNameFileToLoad(SubDir, SubjName, HsSufix, NbLayers, RoiName, InputType)

    if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))

        Filename = ReturnFilename('hs_roi_run_cdt_s-param', ...
                                  SubjName, ...
                                  HsSufix, ...
                                  NbLayers, ...
                                  RoiName, ...
                                  InputType);

    else

        Filename = ReturnFilename('hs_roi_run_cdt_layer', ...
                                  SubjName, ...
                                  HsSufix, ...
                                  NbLayers, ...
                                  RoiName);

    end

    Opt = SetDefaults();
    if Opt.PerformDeconvolution
        Filename = strrep(Filename, '.mat', '_deconvolved-1.mat');
    end

    Filename = fullfile(SubDir, Filename);

    fprintf('   Loading: %s\n', Filename);

end
