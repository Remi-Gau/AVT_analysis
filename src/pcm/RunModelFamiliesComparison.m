% (C) Copyright 2020 Remi Gau
%
% computes exceedance probabilities by performing family comparison
% with spm_compare_families

clc;
clear;
close all;

%% parameters

[ModelType, InputType, ROIs, ConditionType, Dirs] = SetPcm();

Opt = SetDefaults();
Opt = SetPlottingParameters(Opt);

PlotSubject = 1;

InputDir = fullfile(Dirs.PCM, ModelType, 'likelihoods');
OutputDir = fullfile(Dirs.PCM, ModelType, 'model_comparison');

spm_mkdir(OutputDir);

%%

Families = SetModelFamilies(ModelType);

NbROIs = numel(ROIs);

for iROI = 1:NbROIs

    fprintf(1, '\n\n%s\n', ROIs{iROI});

    filename = ['likelihoods', ...
                '_roi-', ROIs{iROI}, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType)];

    if PlotSubject
        filename = [filename '_withSubj-1'];
    end

    fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [filename '.mat']));

    load(fullfile(InputDir, [filename '.mat']), ...
         'Likelihood', 'Models_all', 'Analysis');

    % remove null and free models
    Likelihood(:, [1 end], :) = [];

    % in case we have different types of family comparisons
    for  iFam = 1:numel(Families)

        for iAnalysis = 1:numel(Models_all)

            fprintf(1, '\n %s\n', Analysis(iAnalysis).name);

            %% RFX: perform bayesian model family comparison
            % Compute exceedance probabilities
            for iCdt = 1:numel(Families{iFam})

                family = Families{iFam}{iCdt};
                fprintf(1, '  %s\n', strjoin(family.names, '   '));

                loglike = Likelihood(:, family.modelorder, iAnalysis);

                family = spm_compare_families(loglike, family);

                XP{iFam}(iCdt, :, iAnalysis) = family.xp;

            end

        end
    end

    filename = strrep(filename, 'likelihoods', 'model_comparison');
    save(fullfile(OutputDir, [filename '.mat']), ...
         'XP', 'Models_all', 'Families', 'Analysis');
end
