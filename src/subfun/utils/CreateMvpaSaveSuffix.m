% (C) Copyright 2020 Remi Gau
function SaveSufix = CreateMvpaSaveSuffix(opt, FWHM, NbLayers, space)
    %
    % Creates save suffixes from MVPA save files
    %
    % USAGE::
    %
    %   SaveSufix = CreateMvpaSaveSuffix(opt, FWHM, NbLayers, space)
    %

    if isempty(FWHM)
        FWHM = 0;
    end

    if numel(opt.svm.log2c) == 1
        SaveSufix = ['_results_' lower(space) '_C-' num2str(opt.svm.log2c)];
    else
        SaveSufix = ['_results_' lower(space)];
    end

    if opt.layersubsample.do
        SaveSufix = [SaveSufix '_subsamp-1'];
    else
        SaveSufix = [SaveSufix '_subsamp-0'];
    end

    if opt.MVNN
        SaveSufix = [SaveSufix '_mvnn-1']; %#ok<*AGROW>
    else
        SaveSufix = [SaveSufix '_mvnn-0'];
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

    if opt.session.curve
        SaveSufix = [SaveSufix '_lear-1'];
    else
        SaveSufix = [SaveSufix '_lear-0'];
    end

    if opt.session.loro
        SaveSufix = [SaveSufix '_loro-1'];
    else
        SaveSufix = [SaveSufix '_loro-0'];
    end

    SaveSufix = [SaveSufix '_NORM'];
    if opt.scaling.idpdt
        SaveSufix = [SaveSufix '-Idpdt'];
    end

    SaveSufix = [SaveSufix '_IMG'];
    if opt.scaling.img.zscore
        SaveSufix = [SaveSufix '-ZScore'];
    end
    if opt.scaling.img.eucledian
        SaveSufix = [SaveSufix '-Eucl'];
    end

    SaveSufix = [SaveSufix '_FEAT'];
    if opt.scaling.feat.mean
        SaveSufix = [SaveSufix '-MeanCent'];
    end
    if opt.scaling.feat.range
        SaveSufix = [SaveSufix '-Range'];
    end
    if opt.scaling.feat.sessmean
        SaveSufix = [SaveSufix '-SessMeanCent'];
    end

    if isfield(opt, 'toplot')
        SaveSufix = [SaveSufix '_' opt.toplot];
    end

    if exist('NbLayers', 'var')
        SaveSufix = [SaveSufix '_l-' num2str(NbLayers)];
    end

    if exist('FWHM', 'var')
        SaveSufix = [SaveSufix '_s-' num2str(FWHM)  '.mat'];
    else
        SaveSufix = [SaveSufix '.mat'];
    end

end
