% (C) Copyright 2020 Remi Gau
%
% Plots the G matrices: empirical, free model and then all the fitted of all the models

clc;
clear;
close all;

%% Main parameters

% Choose on what type of data the analysis will be run
%
% b-parameters
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

% This needs to be adapted or even saved with the PCM results
Analysis(1).name = 'Ipsi';
Analysis(2).name = 'Contra';
Analysis(3).name = 'ContraIpsi';

FigDim = [50, 50, 1400, 750];
visible = 'on';

%% Other parameters
% Unlikely to change

IsTarget = false;

DoFeaturePooling = true;

Space = 'surf';

%% Will not change

MVNN = true;

ConditionType = 'stim';
if IsTarget
    ConditionType = 'target';
end

Dirs = SetDir(Space, MVNN);
% TODO
% Change hard coding of model types
InputDir = fullfile(Dirs.PCM, '3X3');

FigureDir = fullfile(InputDir, 'figures');
mkdir(FigureDir);

for iROI = 1:numel(ROIs)

    for ihs = 1:2

        for iAnalysis = 1:numel(Analysis)

            filename = ['pcm_results', ...
                        '_roi-', ROIs{iROI}, ...
                        '_cdt-', ConditionType, ...
                        '_param-', lower(InputType), ...
                        '_analysis-', Analysis(iAnalysis).name, ...
                        '.mat'];
            filename = fullfile(InputDir, filename);

            disp(filename);
            load(filename, 'Models', 'T_grp', 'T_cr');

            Models_all{iAnalysis, 1} = Models; %#ok<*SAGROW>
            T_group_all{iAnalysis, 1} = T_grp;
            T_cross_all{iAnalysis, 1} = T_cr;

            clear Models T_grp T_cr filename;

        end

        c = pcm_indicatorMatrix('allpairs', 1:size(Models_all{1}{1}.Ac, 1));
        % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
        H = 1;

        %% Plot G matrices
        m = 3;
        n = 5;

        close all;

        for iComp = 1:numel(Models_all)

            switch iComp
                case 1
                    CdtToSelect = 1:2:5;
                case 2
                    CdtToSelect = 2:2:6;
            end

            filename = ['Gmatrices', ...
                        '_roi-', ROIs{iROI}, ...
                        '_cdt-', ConditionType, ...
                        '_param-', lower(InputType)];

            figure( ...
                   'name', strrep(filename, '_', ' '), ...
                   'Position', FigDim, ...
                   'Color', [1 1 1], ...
                   'visible', visible);

            ColorMap = BrainColourMaps('hot_increasing');
            colormap(ColorMap);

            Subplot = 1;

            % Get info
            G_hat = G_hat_all{iComp, 1};
            G_pred_cr = G_pred_cr_all{iComp, 1};
            M = M_all{iComp, 1};

            % CVed G_{emp}
            subplot(m, n, Subplot);

            tmp = H * mean(G_hat, 3) * H';
            MIN_MAX = max(abs([min(tmp(:)) max(tmp(:))]));
            CLIM = [MIN_MAX * -1 MIN_MAX];
            imagesc(tmp, CLIM);
            colorbar;

            set(gca, ...
                'tickdir', 'out', ...
                'xtick', 1:3, ...
                'xticklabel', [], ...
                'ytick', 1:3, ...
                'yticklabel', {CondNames{CdtToSelect}}, ...
                'ticklength', [0.01 0], ...
                'fontsize', 8);
            box off;
            axis square;
            t = title('G_{emp} CV');
            set(t, 'fontsize', 8);

            Subplot = Subplot + 1;

            % CVed G_{pred} free model
            subplot(m, n, Subplot);

            tmp = H * mean(G_pred_cr{end}, 3) * H';
            MIN_MAX = max(abs([min(tmp(:)) max(tmp(:))]));
            CLIM = [MIN_MAX * -1 MIN_MAX];
            imagesc(tmp, CLIM);
            colorbar;

            set(gca, ...
                'tickdir', 'out', ...
                'xtick', 1:3, ...
                'xticklabel', [], ...
                'ytick', 1:3, ...
                'yticklabel', {CondNames{CdtToSelect}}, ...
                'ticklength', [0.01 0], ...
                'fontsize', 8);
            box off;
            axis square;
            t = title('G_{pred} free CV');
            set(t, 'fontsize', 6);

            Subplot = Subplot + 1;

            % plot pred G mat from each model
            for iModel = 2:13
                subplot(m, n, Subplot);

                tmp = H * mean(G_pred_cr{iModel}, 3) * H';
                MIN_MAX = max(abs([min(tmp(:)) max(tmp(:))]));
                CLIM = [MIN_MAX * -1 MIN_MAX];
                imagesc(tmp, CLIM);
                colorbar;

                set(gca, ...
                    'tickdir', 'out', ...
                    'xtick', 1:3, ...
                    'xticklabel', [], ...
                    'ytick', 1:3, ...
                    'yticklabel', {CondNames{CdtToSelect}}, ...
                    'ticklength', [0.01 0], ...
                    'fontsize', 8);
                box off;
                axis square;
                t = title([num2str(iModel - 1) ' - ' strrep(M{iModel}.name, '_', ' ')]);
                set(t, 'fontsize', 8);

                Subplot = Subplot + 1;
            end

            mtit(opt.FigName, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

            print(gcf, fullfile(PCM_dir, 'Cdt', '3X3_models', [opt.FigName '.tif']), '-dtiff');

        end

    end
end
