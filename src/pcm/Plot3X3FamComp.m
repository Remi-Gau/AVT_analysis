% (C) Copyright 2020 Remi Gau
%
% For 3X3 models
%
% - computes likelihood of each model
% - computes exceedance probabilities by performing 2 family comparison with spm_compare_families
%
%           a) Families.names{1}='Scaled';
%           b) Families.names{2}='Scaled+Idpdt and Idpdt';
%
% or
%           a) Families.names{1}='Scaled';
%           b) Families.names{2}='Scaled+Idpdt'
%           c) Families.names{3}='Idpdt'
%
% - plot the exceedance probabilities for both cases as a matrix
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
InputDir = fullfile(Dirs.PCM, ModelType, 'likelihoods');
OutputDir = fullfile(Dirs.PCM, ModelType, 'model_comparison');
FigureDir = fullfile(Dirs.PCM, ModelType, 'figures', 'model_comparison');

Families = Set3X3modelsFamily();

NbROIs = numel(ROIs);

for iROI = 1:NbROIs

    disp(ROIs{iROI});

    filename = ['likelihoods', ...
                '_roi-', ROIs{iROI}, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType)];

    if PlotSubject
        filename = [filename '_withSubj-1'];
    end

    load(fullfile(InputDir, [filename '.mat']), 'Likelihood', 'Models_all');

    % Likelihood(:, :, iAnalysis) = T.likelihood;

    XP = {};

    for  iFam = 1:numel(Families)

        for iAnalysis = 1:numel(Models_all)

            %% RFX: perform bayesian model family comparison
            % Compute exceedance probabilities
            for iCdt = 1:numel(Families)

                family = Families{iFam}{iCdt};

                loglike = Likelihood(:, family.modelorder + 1, iAnalysis);

                family = spm_compare_families(loglike, family);

                XP{iFam}(iCdt, :, iAnalysis) = family.xp;

            end

        end
    end

    filename = strrep(filename, 'likelihoods', 'model_comparison');
    save(fullfile(OutputDir, [filename '.mat']), 'XP', 'Models_all', 'Families');
end

return

%% Matrices plot for exceedance probability of I + (S & I)
close all;

for iFam = 1:2

    Struct2Save = struct( ...
                         'comp', { ...
                                  { ...
                                   'Ai VS Vi', 'Ai VS Ti', 'Vi VS Ti', ...
                                   'Ac VS Vc', 'Ac VS Tc', 'Vc VS Tc' ...
                                  } ...
                                 }, ...
                         'p_s', [], ...
                         'p_si', [], ...
                         'p_i', []);

    for iAnalysis = 1:size(XP, 4)

        if iFam == 1
            NbFam = '3';
            Mat2Plot = squeeze(XP(:, 3, :, iAnalysis) + XP(:, 1, :, iAnalysis));
            Struct2Save = cat(1, ...
                              XP([2 1 3], :, :, iAnalysis), ...
                              XP([2 1 3], :, :, iAnalysis));

        else
            NbFam = '2';
            Mat2Plot = squeeze(XP2(:, 1, :, iAnalysis));
            Struct2Save = zeros(6, 3, NbROIs);

        end

        filename = ['ModelFamilyComparison', ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '_NbFamilies-', NbFam];

        figure( ...
               'name', strrep(filename, '_', ' '), ...
               'Position', FigDim);

        SetFigureDefaults(Opt);

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

        p = mtit(['Exc probability Idpt + Scaled & Idpdt - ' InputType], ...
                 'fontsize', 14, ...
                 'xoff', 0, 'yoff', .025);

        axis([.5 NbROIs + .5 .5 3.5]);
        axis square;

        ColorMap = BrainColourMaps('hot_increasing');
        colormap(ColorMap);
        disp(filename);
        print(gcf, fullfile(FigureDir, [filename '_hot.tif']), '-dtiff');

    end

end
