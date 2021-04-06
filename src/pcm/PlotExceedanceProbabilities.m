% (C) Copyright 2020 Remi Gau

%
% plot the exceedance probabilities for all ROIs as a matrix
%

clc;
clear;
close all;

%% Main parameters

% '3X3', '6X6', 'subset6X6'
ModelType = '3X3';

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
        'A1'
        'PT'
        'V1'
        'V2'
       };

%% Other parameters

MVNN = true;
Space = 'surf';

Opt = SetDefaults();
Opt = SetPlottingParameters(Opt);

ConditionType = 'stim';
if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
end

PlotSubject = 1;

Dirs = SetDir(Space, MVNN);
InputDir = fullfile(Dirs.PCM, ModelType, 'model_comparison');
FigureDir = fullfile(Dirs.PCM, ModelType, 'figures', 'model_comparison');

ColorMapDir = fullfile(fileparts(which('map_luminance')), '..', 'mat_maps');
load(fullfile(ColorMapDir, '1hot_iso.mat'));
ColorMap = hot;

NbROIs = numel(ROIs);

for iROI = 1:NbROIs

    fprintf(1, '%s\n', ROIs{iROI});

    filename = ['model_comparison', ...
                '_roi-', ROIs{iROI}, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType)];

    if PlotSubject
        filename = [filename '_withSubj-1'];
    end

    fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [filename '.mat']));

    load(fullfile(InputDir, [filename '.mat']), ...
         'XP', 'Models_all', 'Families', 'Analysis');

    for i = 1:numel(XP)
        ExceedProba{i}(:, :, :, iROI) = XP{i}; %#ok<SAGROW>
    end

    clear XP;
end

%% Matrices plot for exceedance probability of I + (S & I)

for iFam = 1:numel(ExceedProba)

    %     Struct2Save = struct( ...
    %                          'comp', { ...
    %                                   { ...
    %                                    'Ai VS Vi', 'Ai VS Ti', 'Vi VS Ti', ...
    %                                    'Ac VS Vc', 'Ac VS Tc', 'Vc VS Tc' ...
    %                                   } ...
    %                                  }, ...
    %                          'p_s', [], ...
    %                          'p_si', [], ...
    %                          'p_i', []);

    XP = ExceedProba{iFam};

    NbFam = numel(Families{iFam}{1}.names);

    for iAnalysis = 1:size(XP, 3)

        if iFam == 1
            Mat2Plot = squeeze(XP(:, 3, iAnalysis, :) + XP(:, 1, iAnalysis, :));
            Struct2Save = cat(1, ...
                              XP([2 1 3], :, iAnalysis, :), ...
                              XP([2 1 3], :, iAnalysis, :));

        elseif iFam == 2
            Mat2Plot = squeeze(XP(:, 1, iAnalysis, :));
            Struct2Save = zeros(6, 3, NbROIs);

        end

        filename = ['model_comparison', ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '_nbFamilies-', num2str(NbFam)];

        Opt.Title = strrep(filename, '_', ' ');
        Opt = OpenFigure(Opt);

        colormap('gray');

        hold on;
        box off;

        imagesc(flipud(Mat2Plot), [0 1]);

        plot([.5 NbROIs + .5], [1.5 1.5], 'color', [.2 .2 .2], 'linewidth', 1);
        plot([.5 NbROIs + .5], [2.5 2.5], 'color', [.2 .2 .2], 'linewidth', 1);
        for i = 1:4
            plot([0.5 0.5] + i, [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1);
        end

        patch([2.44 2.56 2.56 2.44], [.5 .5 3.5 3.5], 'w', 'linewidth', 2);

        plot([.5 .5], [.5 3.5], 'k', 'linewidth', 2);
        plot([NbROIs + .5 NbROIs + .5], [.5 3.5], 'k', 'linewidth', 2);
        plot([.5 NbROIs + .5], [.5 .5], 'k', 'linewidth', 2);
        plot([.5 NbROIs + .5], [3.5 3.5], 'k', 'linewidth', 2);

        title(Analysis(iAnalysis).name);

        switch iAnalysis
            case 1
                yticklabel = ['V_i VS T_i'; 'A_i VS T_i'; 'A_i VS V_i'];
            case 2
                yticklabel = ['V_c VS T_c'; 'A_c VS T_c'; 'A_c VS V_c'];
            case 3
                yticklabel = ['V VS T'; 'A VS T'; 'A VS V'];
        end

        set(gca, 'fontsize', 10, ...
            'ytick', 1:3, ...
            'yticklabel', yticklabel, ...
            'xtick', 1:NbROIs, ...
            'xticklabel', ROIs(1:NbROIs), 'Xcolor', 'k');

        colorbar;

        axis([.5 NbROIs + .5 .5 3.5]);
        axis square;

        colormap(ColorMap);

        mtit([Opt.Title ' - ' InputType], ...
             'fontsize', Opt.Fontsize, ...
             'xoff', 0, 'yoff', .025);

        PrintFigure(FigureDir);

    end

end
