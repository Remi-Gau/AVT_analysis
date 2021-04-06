% (C) Copyright 2020 Remi Gau
%
%  First plots the G matrices:
%  - empirical,
%  - cross validated free model
%  - then that all the fitted of all the models

clc;
clear;
close all;

%% Main parameters

% '3X3', '6X6', 'subset6X6'
ModelType = 'subset6X6';

% Choose on what type of data the analysis will be run
%
% b-parameters
%
% 'ROI'
%
% s-parameters
%
% 'Cst', 'Lin', 'Quad'
%

InputType = 'Cst';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
        'V1'
        'V2'
        'A1'
        'PT'
       };

Analysis = BuildModels(ModelType);

Opt = SetRasterPlotParameters();
ColorMap = Opt.Raster.ColorMap;

Opt.FigDim = [50 50 2400 2000];

%% Other parameters

ConditionType = 'stim';
if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
end

Space = 'surf';
MVNN = true;
Dirs = SetDir(Space, MVNN);

InputDir = fullfile(Dirs.PCM, ModelType);

FigureDir = fullfile(InputDir, 'figures', 'model_G_matrices');

for iROI = 1:numel(ROIs)

    for iAnalysis = 1:numel(Analysis)

        filename = ['pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '.mat'];

        if Opt.PerformDeconvolution
            filename = strrep(filename, '.mat', '_deconvolved-1.mat');
        end

        if strcmp(ModelType, 'subset6X6')
            filename = ['group_' filename];
        end

        filename = fullfile(InputDir, filename);

        fprintf(1, 'loading:\n %s\n', filename);
        load(filename, 'Models', 'G_hat', 'G_pred_grp', 'G_pred_cr');

        %% Plot G matrices
        FigureFilename = ['G_matrices', ...
                          '_roi-', ROIs{iROI}, ...
                          '_cdt-', ConditionType, ...
                          '_param-', lower(InputType), ...
                          '_analysis-', Analysis(iAnalysis).name];

        Opt.Title = strrep(FigureFilename, '_', ' ');

        Opt = OpenFigure(Opt);

        colormap(ColorMap);

        [m, n] = OptimizeSubplotNumber(numel(Models));

        Subplot = 1;

        % CVed G_{emp}
        subplot(m, n, Subplot);

        PlotGMatrixAndSetAxis(mean(G_hat, 3), ...
                              Analysis(iAnalysis).CondNames, ...
                              'G_{emp} CV', Opt.Fontsize);

        Subplot = Subplot + 1;

        % CVed G_{pred} free model
        subplot(m, n, Subplot);

        PlotGMatrixAndSetAxis(mean(G_pred_cr{end}, 3), ...
                              Analysis(iAnalysis).CondNames, ...
                              'G_{pred} free CV', ...
                              Opt.Fontsize);

        Subplot = Subplot + 1;

        % plot pred G mat from each model
        for iModel = 2:(numel(Models) - 1)

            subplot(m, n, Subplot);

            Title = [num2str(iModel - 1) ' - ' strrep(Models{iModel}.name, '_', ' ')];
            PlotGMatrixAndSetAxis(mean(G_pred_cr{iModel}, 3), ...
                                  Analysis(iAnalysis).CondNames, ...
                                  Title, ...
                                  Opt.Fontsize);

            Subplot = Subplot + 1;

        end

        mtit(get(gcf, 'name'), ...
             'fontsize', Opt.Fontsize, ...
             'xoff', 0, ...
             'yoff', .035);

        PrintFigure(FigureDir);

    end

end
