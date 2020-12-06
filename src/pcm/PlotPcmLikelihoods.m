% (C) Copyright 2020 Remi Gau
% Plot the results of the 3X3 PCM
% First plots the G matrices: empirical, free model and then all the fitted of all the models
% Then gives the bar plot of the likelihoods of the different models

clc;
clear;
close all;

%% Main parameters

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

InputType = 'ROI';

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

PlotSubject = true;

FigDim = [50, 50, 1400, 750];
Visible = 'on';

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

if PlotSubject
    [SubLs, NbSub] = GetSubjectList();
    COLOR_SUBJECTS = SubjectColours();
end

FigureDir = fullfile(InputDir, 'figures');
mkdir(FigureDir);

for iROI = 1:numel(ROIs)

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

    %% Plot of the likelihoods as bar plots
    clear Likelihood;

    filename = ['likelihoods', ...
                '_roi-', ROIs{iROI}, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType)];

    if PlotSubject
        filename = [filename '_withSubj-1'];
    end

    figure( ...
           'name', strrep(filename, '_', ' '), ...
           'Position', FigDim, ...
           'Color', [1 1 1], ...
           'visible', Visible);

    Subplot = 1;

    for iAnalysis = 1:numel(Models_all)

        for Normalize = 0:1

            colors = {'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'};

            subplot(numel(Models_all), 2, Subplot);

            Upperceil = T_group_all{iAnalysis, 1}.likelihood(:, end);
            Data2Plot = T_cross_all{iAnalysis, 1};
            M = Models_all{iAnalysis, 1};

            T = pcm_plotModelLikelihood( ...
                                        Data2Plot, M, ...
                                        'upperceil', Upperceil, ...
                                        'colors', colors, ...
                                        'normalize', Normalize);

            if Normalize == 1

                loglike = mean(T.likelihood_norm(:, 2:end - 1));
                [loglike_sorted, idx] = sort(mean(T.likelihood_norm(:, 2:end - 1)));

                if loglike(idx(end - 1)) + 3 < loglike(idx(end))

                    colors{idx(end)} = 'r';

                    T = pcm_plotModelLikelihood( ...
                                                Data2Plot, M, ...
                                                'upperceil', Upperceil, ...
                                                'colors', colors, ...
                                                'normalize', Normalize);

                end

            end

            if PlotSubject

                hold on;

                Scatter = linspace(-.3, .3, NbSub);

                for iM = 2:numel(M) - 1
                    for isubj = 1:NbSub
                        plot(iM - 1 + Scatter(isubj), T.likelihood_norm(isubj, iM), ...
                             'marker', 'o', ...
                             'MarkerSize', 3, ...
                             'MarkerEdgeColor', COLOR_SUBJECTS(isubj, :), ...
                             'MarkerFaceColor', COLOR_SUBJECTS(isubj, :));
                    end
                end

            end

            ylabel('');

            set(gca, 'fontsize', 8, ...
                'xtick', 1:12, ...
                'xticklabel', 1:12);

            Data = T.likelihood_norm(:, 2:end - 1);

            if PlotSubject
                MIN = min(Data(:));

                MAX = max(Data(:));
                MAX = MAX * 1.1;

            else
                MIN = min(mean(Data)) - ...
                  max(nansem(Data)) / 4; %#ok<*UNRCH>

                MAX = max(mean(Data)) + ...
                  max(nansem(Data));
                MAX = MAX * 1.005;
                if MAX < 1.005
                    MAX = 1.005;
                end

            end

            if iAnalysis == 1

                temp = 'Log-likelihood - Cross validation';
                if Normalize == 1
                    temp = ['Normalized ' temp]; %#ok<*AGROW>
                end

                t = title(temp);
                set(t, 'fontsize', 12);

            end

            if Normalize == 0
                t = ylabel(Analysis(iAnalysis).name);
                set(t, 'fontsize', 14);
            end

            axis([0.5 12.5 0 MAX]);

            Subplot = Subplot + 1;

        end

    end

    mtit(strrep(filename, '_', ' '), ...
         'fontsize', 12, ...
         'xoff', 0, ...
         'yoff', .035);
    set(gcf, 'visible', Visible');

    filename = fullfile(FigureDir, [filename '.tif']);
    disp(filename);
    print(gcf, filename, '-dtiff');

end
