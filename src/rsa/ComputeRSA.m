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

    NbHs = size(GrpData, 2);

    for hs = 1:NbHs

        Filename = GetRsaFilename(NbHs, hs, ROIs{iROI}, ConditionType, InputType, Opt);

        for iSub = 1:NbSub
            RDMs(:, :, iSub) = ComputeCvedSquaredEuclidianDist(GrpData{iSub}, ...
                                                               GrpRunVec{iSub}, ...
                                                               GrpConditionVec{iSub}); %#ok<SAGROW>
        end

        save(fullfile(OutputDir, Filename), ...
             'Analysis', ...
             'CondNames', ...
             'GrpRunVec', 'GrpConditionVec', ...
             'RDMs');

    end

end
