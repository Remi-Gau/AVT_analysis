% (C) Copyright 2021 Remi Gau
%
% Runs RSA computation

% TODO
% - Make it run on the b parameters
% - Make it run on volume
%

clc;
clear;
close all;

[InputType, ROIs, Opt, ConditionType, Analysis, CondNames, Dirs] = SetRsa;

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
