% (C) Copyright 2020 Remi Gau
function SaveSufix = return_mvpa_suffix(opt, NbLayers)
    %
    % Creates save suffixes from MVPA save files
    %
    % USAGE::
    %
    %   SaveSufix = CreateMvpaSaveSuffix(opt, NbLayers)
    %

    if nargin < 3 || isempty(NbLayers)
        NbLayers = 6;
    end

    SaveSufix = ['_' opt.input];
    if numel(opt.svm.log2c) == 1
        SaveSufix = ['_C-' num2str(opt.svm.log2c)];
    end

    if opt.layersubsample.do
        SaveSufix = [SaveSufix '_subsamp-1'];
    else
        SaveSufix = [SaveSufix '_subsamp-0'];
    end

    if opt.fs.do
        SaveSufix = [SaveSufix '_fs-1'];
    else
        SaveSufix = [SaveSufix '_fs-0'];
    end

    if opt.rfe.do
        SaveSufix = [SaveSufix '_rfe-1'];
    else
        SaveSufix = [SaveSufix '_rfe-0'];
    end

    if opt.permutation.test
        SaveSufix = [SaveSufix '_perm-1'];
    else
        SaveSufix = [SaveSufix '_perm-0'];
    end

    if opt.runs.curve
        SaveSufix = [SaveSufix '_lear-1'];
    else
        SaveSufix = [SaveSufix '_lear-0'];
    end

    if opt.runs.loro
        SaveSufix = [SaveSufix '_loro-1'];
    else
        SaveSufix = [SaveSufix '_loro-0'];
    end

    SaveSufix = [SaveSufix '_norm'];
    if opt.scaling.idpdt
        SaveSufix = [SaveSufix '-idpdt'];
    end
    SaveSufix = [SaveSufix '_img-' opt.scaling.img.type];
    SaveSufix = [SaveSufix '_feat-' opt.scaling.feat.type];

    SaveSufix = [SaveSufix '_nbLayers-' num2str(NbLayers)];
    SaveSufix = [SaveSufix '.mat'];

end
