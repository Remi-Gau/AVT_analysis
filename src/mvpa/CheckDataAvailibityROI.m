clc;
clear;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

Targ = 0;

Cdt_ROI_lhs = 1:6;
Cdt_ROI_rhs = [2 1 4 3 6 5];

if Targ
    pattern = 'Targ';
else
    pattern = 'Stim'; %#ok<*UNRCH>
end

CondNames = { ...
             ['A' pattern 'L'], ['A' pattern 'R'], ...
             ['V' pattern 'L'], ['V' pattern 'R'], ...
             ['T' pattern 'L'], ['T' pattern 'R'] ...
            };

% --------------------------------------------------------- %
%              Classes and associated conditions            %
% --------------------------------------------------------- %
Class(1) = struct('name', ['A ' pattern ' - Left'], 'cond', cell(1), 'nbetas', 1);
Class(end).cond = CondNames(1);

Class(2) = struct('name', ['A ' pattern ' - Right'], 'cond', cell(1), 'nbetas', 1);
Class(end).cond = CondNames(2);

Class(3) = struct('name', ['V ' pattern ' - Left'], 'cond', cell(1), 'nbetas', 1);
Class(end).cond = CondNames(3);

Class(4) = struct('name', ['V ' pattern ' - Right'], 'cond', cell(1), 'nbetas', 1);
Class(end).cond = CondNames(4);

Class(5) = struct('name', ['T ' pattern ' - Left'], 'cond', cell(1), 'nbetas', 1);
Class(end).cond = CondNames(5);

Class(6) = struct('name', ['T ' pattern ' - Right'], 'cond', cell(1), 'nbetas', 1);
Class(end).cond = CondNames(6);

ROIs_ori = {
            'A1', ...
            'PT', ...
            'V1', ...
            'V2', ...
            'V3', ...
            'V4', ...
            'V5'};

for iSub = 1:NbSub

    % --------------------------------------------------------- %
    %                        Subject data                       %
    % --------------------------------------------------------- %
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    SubDir = fullfile(StartDir, SubLs(iSub).name);

    if Targ
        Data_dir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf', 'targets');
    else
        Data_dir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf');
    end

    SaveDir = fullfile(SubDir, 'results', 'SVM');
    [~, ~, ~] = mkdir(SaveDir);

    % Load Vertices of interest for each ROI;
    load(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    %% Gets the number of each beta images and the numbers of the beta of interest
    load(fullfile(SubDir, 'ffx_nat', 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    for i = 1:size(BetaNames, 1)
        if BetaNames(i, 6) == ' '
            tmp(i, 1:6) = BetaNames(i, 7:12); %#ok<*AGROW>
        else
            tmp(i, 1:6) = BetaNames(i, 8:13);
        end
    end
    BetaNames = tmp;

    %% Creates a dataset that lists for each beta of interest:

    % For each condition of each class we figure out what is the associated
    % regressors and in which sessions they occur.

    BetaList_lh = [];
    BetaList_rh = [];
    for iClass = 1:numel(Class)

        tmp = BetaNames(BetaOfInterest, :);

        TEMP = BetaOfInterest(strcmp(Class(Cdt_ROI_lhs(iClass)).cond, cellstr(tmp)));
        BetaList_lh = [BetaList_lh; TEMP];

        TEMP = BetaOfInterest(strcmp(Class(Cdt_ROI_rhs(iClass)).cond, cellstr(tmp)));
        BetaList_rh = [BetaList_rh; TEMP];

    end
    clear irow iClass iCond BetaNames iFile RegNumbers;

    %% Read features
    fprintf(' Reading features\n');
    for hs = 1:2

        if hs == 1
            fprintf('  Left hemipshere\n');
            HsSufix = 'l';
        else
            fprintf('  Right hemipshere\n');
            HsSufix = 'r';
        end

        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);

        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile, 'AllMapping', 'inf_vertex', 'VertexWithData');
            Mapping_both_hs{hs} = AllMapping; %#ok<*SAGROW>
            VertexWithDataHS{hs} = VertexWithData;
            NbVertex(hs) = size(inf_vertex, 2);
        else
            error('The features have not been extracted from the VTK files.');
        end

    end

    %% Redistribute features into each ROI
    FeaturesAll = cell(numel(ROI), 1); %#ok<*USENS>

    [~, LOCB_lh] = ismember(BetaList_lh, BetaOfInterest);
    [~, LOCB_rh] = ismember(BetaList_rh, BetaOfInterest);

    for iExemplar = 1:numel(LOCB_lh)

        Profiles_lh = nan(NbVertex(1), 6);
        Profiles_rh = nan(NbVertex(2), 6);

        Profiles_lh(VertexWithDataHS{1}, :) = Mapping_both_hs{1}(:, :, LOCB_lh(iExemplar));
        Profiles_rh(VertexWithDataHS{2}, :) = Mapping_both_hs{2}(:, :, LOCB_rh(iExemplar));

        for iROI = 1:numel(ROI)

            Feat_L = (Profiles_lh(ROI(iROI).VertOfInt{1}, :))';
            Feat_R = (Profiles_rh(ROI(iROI).VertOfInt{2}, :))';

            FeaturesAll{iROI} = [FeaturesAll{iROI}; [(Feat_L(:))' (Feat_R(:))']];

        end

    end

    fprintf('Analysing subject %s\n', SubLs(iSub).name);
    for iROI = 1:numel(ROI)

        fprintf('  Running ROI:  %s\n', ROIs_ori{iROI});
        fprintf('  Number of vertices before FS/RFE: %i\n', sum(cellfun('length', ROI(iROI).VertOfInt)));

        FeaturesBoth = FeaturesAll{iROI, 1};
        FeaturesLayersBoth = repmat(NbLayers:-1:1, 1, size(FeaturesBoth, 2) / NbLayers);

        % create a logical index that is true when all depth of a
        % vertex have date
        LogFeatBoth = any(isnan(FeaturesBoth));
        LogFeatBoth = reshape(LogFeatBoth', [NbLayers, numel(LogFeatBoth) / NbLayers]);
        A = sum(all(LogFeatBoth));
        B = sum(any(LogFeatBoth));
        if A > 0
            warning('  %i vertices are missing data at all depths.', A);
        end
        if (B - A) > 0
            warning('  %i vertices are missing data at some depths.', B - A);
        end

    end % iSubROI=1:numel(SVM(iSVM).ROI)

end % for iSub = 1:NbSub
