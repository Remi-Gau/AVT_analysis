% (C) Copyright 2020 Remi Gau
%
% Script to check that each beta of intereste has been mapped onto a surface.
%

clc;
clear;

% To work on the beta values that have undergone multivariate noise normalization
MVNN = false;

%%
NbLayers = 6;

CondNames = GetConditionList();

Dirs = SetDir('surf', MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExternalHD);

for iSub = 1:NbSub

    fprintf('Processing %s\n', SubLs(iSub).name);

    OuputDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);
    [~, ~, ~] = mkdir(OuputDir);

    SubDir = fullfile(Dirs.ExternalHD, SubLs(iSub).name);

    InputDir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf');
    if MVNN
        InputDir = fullfile(SubDir, 'ffx_rsa', 'betas', '6_surf');
    end

    %% Load data or extract them

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(SubDir, 'ffx_nat', 'SPM.mat'));
    [BetaOfInterest, BetaNames] =  GetBOI(SPM, CondNames);
    NbBetas = numel(BetaOfInterest);
    clear SPM;

    for hs = 1:2

        if hs == 1
            HsSufix = 'l';
            fprintf(' Left HS\n');
        else
            HsSufix = 'r';
            fprintf(' Right HS\n');
        end

        for iBeta = 1:size(BetaOfInterest, 1)

            Betas = spm_select('FPList', ...
                               InputDir, ...
                               ['^Beta.*' sprintf('%04.0f', BetaOfInterest(iBeta)) '.*' HsSufix 'cr.vtk$']);

            if isempty(Betas)
                error('missing beta');
            else
                disp(Betas);
            end

        end

    end

end
