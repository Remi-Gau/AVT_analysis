% (C) Copyright 2020 Remi Gau
%
% Runs RSA computation

% TODO
% - Make it run on the b parameters
% - Make it run on volume
%

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

InputType = 'Cst';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
        'V1'
        'V2'
        'A1'
        'PT'
       };

%% Other parameters

Opt = SetDefaults();

Opt.CombineHemisphere = true;

Space = 'surf';
MVNN = true;

%%
ConditionType = 'stim';
Analysis.name = 'all_stim';
Analysis.CdtToSelect = 1:6;

if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
    Analysis.CdtToSelect = 7:12;
    Analysis.name = 'all_target';
end

CondNames = GetConditionList();
CondNames = CondNames(Analysis.CdtToSelect);

% TODO
% This input dir might have to change if we are dealing with volume data
Dirs = SetDir(Space, MVNN);
InputDir = Dirs.ExtractedBetas;
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    InputDir = Dirs.LaminarGlm;
end

OutputDir = Dirs.RSA;
spm_mkdir(OutputDir);

%% Start
fprintf('Get started\n');

for iROI =  1:numel(ROIs)

    [GrpDataSource, GrpConditionVecSource, GrpRunVecSource] = LoadAndPreparePcmData(ROIs{iROI}, ...
                                                                                    InputDir, ...
                                                                                    Opt, ...
                                                                                    InputType);

    [GrpData, GrpRunVec, GrpConditionVec] = PreparePcmInput(GrpDataSource, ...
                                                            GrpConditionVecSource, ...
                                                            GrpRunVecSource, ...
                                                            Analysis);

    [SubLs, NbSub] = GetSubjectList(InputDir);

    for hs = 1:size(GrpData, 2)

        hs_entity = '';

        if size(GrpData, 2) > 1
            hs_entity = '_hemi-';
            if hs == 1
                label = 'L';
            else
                label = 'R';
            end
            hs_entity = [hs_entity label];
        end

        Filename = ['rsa_results', ...
                    '_roi-', ROIs{iROI}, ...
                    hs_entity, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '.mat'];

        if Opt.PerformDeconvolution
            Filename = strrep(Filename, '.mat', '_deconvolved-1.mat');
        end

        for iSub = 1:NbSub
            RDMs(:, :, iSub) = ComputeCvedSquaredEuclidianDist(GrpData{iSub}, ...
                                                               GrpRunVec{iSub}, ...
                                                               GrpConditionVec{iSub}); %#ok<SAGROW>
        end

        save(fullfile(OutputDir, ['group_' Filename]), ...
             'Analysis', ...
             'CondNames', ...
             'GrpRunVec', 'GrpConditionVec', ...
             'RDMs');

    end

end
