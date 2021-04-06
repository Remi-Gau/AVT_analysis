% (C) Copyright 2020 Remi Gau
%
% computes exceedance probabilities by performing family comparison 
% with spm_compare_families

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

spm_mkdir(OutputDir);

%%

Families = SetModelFamilies(ModelType);

NbROIs = numel(ROIs);

for iROI = 1:NbROIs

    fprintf(1, '%s\n', ROIs{iROI});

    filename = ['likelihoods', ...
                '_roi-', ROIs{iROI}, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType)];

    if PlotSubject
        filename = [filename '_withSubj-1'];
    end

    load(fullfile(InputDir, [filename '.mat']), ...
        'Likelihood', 'Models_all', 'Analysis');

    % Likelihood(:, :, iAnalysis) = T.likelihood;

    XP = {};

    % in case we have different types of family comparisons
    for  iFam = 1:numel(Families)

        for iAnalysis = 1:numel(Models_all)
            
            fprintf(1, '\n %s\n', Analysis(iAnalysis).name);

            %% RFX: perform bayesian model family comparison
            % Compute exceedance probabilities
            for iCdt = 1:numel(Families{iFam})

                family = Families{iFam}{iCdt};
                fprintf(1, '  %s\n', strjoin(family.names, '   ')); 

                loglike = Likelihood(:, family.modelorder + 1, iAnalysis);

                family = spm_compare_families(loglike, family);

                XP{iFam}(iCdt, :, iAnalysis) = family.xp;

            end

        end
    end

    filename = strrep(filename, 'likelihoods', 'model_comparison');
    save(fullfile(OutputDir, [filename '.mat']), ...
        'XP', 'Models_all', 'Families', 'Analysis');
end

