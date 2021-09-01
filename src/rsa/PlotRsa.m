% (C) Copyright 2021 Remi Gau
%
%  Plots RSAs

clc;
clear;
close all;

IsPlotRankTrans = false;

[InputType, ROIs, Opt, ConditionType, Analysis, CondNames, Dirs] = SetRsa;

Opt = SetPlottingParameters(Opt);

ColorMapFolder = fullfile(fileparts(which('loadLutSub')), '..', 'mat_maps');
load(fullfile(ColorMapFolder, '1hot_iso.mat'), 'hot');
ColorMap = [];

[SubLs, NbSub] = GetSubjectList(Dirs.LaminarGlm);

InputDir = Dirs.RSA;
FigureDir = fullfile(Dirs.Figures, 'rsa');

%%

NbHs = 1;
if Opt.CombineHemisphere
    HsLabels = 'LR';
    NbHs = length(HsLabels);
end

for iROI = 1:numel(ROIs)

    for hs = 1:NbHs

        Filename = GetRsaFilename(NbHs, hs, ROIs{iROI}, ConditionType, InputType, Opt);

        load(fullfile(InputDir, Filename));

        %% Plot G matrices
        FigureFilename = strrep(Filename, '.mat', '');

        Opt.Title = strrep(FigureFilename, '_', ' ');

        Opt = OpenFigure(Opt);

        CLIM = [min(RDMs(:)) max(RDMs(:))];
        if IsPlotRankTrans
            CLIM = [0 1];
        end
        Aspect = 1;
        Imagelabels = [];
        ShowColorbar = false;

        %         RDMs = mean(RDMs, 3)

        rsa.fig.showRDMs(RDMs, gcf, IsPlotRankTrans, ...
                         CLIM, ShowColorbar, Aspect, Imagelabels, ColorMap);

        PrintFigure(FigureDir);

        colormap(ColorMap);

    end
end
