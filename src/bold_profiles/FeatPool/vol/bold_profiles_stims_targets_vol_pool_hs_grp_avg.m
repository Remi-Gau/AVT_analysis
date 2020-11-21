% (C) Copyright 2020 Remi Gau
function bold_profiles_stims_targets_vol_pool_hs_grp_avg
    clc;
    clear;

    StartDir = fullfile(pwd, '..', '..', '..');
    cd (StartDir);

    ResultsDir = fullfile(StartDir, 'results', 'profiles');
    [~, ~, ~] = mkdir(ResultsDir);

    SubLs = dir('sub*');
    NbSub = numel(SubLs);

    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

    NbLayers = 6;

    CondNames = { ...
                 'AStimL', 'AStimR'; ...
                 'VStimL', 'VStimR'; ...
                 'TStimL', 'TStimR'; ...
                 'ATargL', 'ATargR'; ...
                 'VTargL', 'VTargR'; ...
                 'TTargL', 'TTargR' ...
                };

    ROIs = { ...
            'A1', ...
            'V1_thres', ...
            'V2_thres', ...
            'V3_thres', ...
            'V4_thres', ...
            'V5_thres', ...
            'PT'};

    DesMat = (1:NbLayers) - mean(1:NbLayers);
    DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
    % DesMat = [DesMat' ones(NbLayers,1)];
    DesMat = spm_orth(DesMat);

    for iROI = 1:length(ROIs)
        AllSubjects_Data(iROI) = struct( ...
                                        'name', ROIs{iROI}); %#ok<*AGROW>
    end

    Median = 1;

    %% Gets data for each subject
    for iSub = 1:NbSub

        SubDir = fullfile(StartDir, SubLs(iSub).name);
        SaveDir = fullfile(SubDir, 'results', 'profiles');

        for iROI = 1:numel(ROIs)

            File2Load = fullfile(SaveDir, strcat('Data_stims_targets_Pooled_', AllSubjects_Data(iROI).name, '_l-', ...
                                                 num2str(NbLayers), '.mat'));

            if exist(File2Load, 'file')

                load(File2Load, 'Data_ROI');

                if Median

                    AllSubjects_Data(iROI).StimTargIpsi.DATA{iSub} = Data_ROI.StimTargIpsi.LayerMedian;
                    AllSubjects_Data(iROI).StimTargIpsi.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.StimTargIpsi.LayerMedian, 2));

                    AllSubjects_Data(iROI).StimTargContra.DATA{iSub} = Data_ROI.StimTargContra.LayerMedian;
                    AllSubjects_Data(iROI).StimTargContra.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.StimTargContra.LayerMedian, 2));

                else

                    AllSubjects_Data(iROI).StimTargIpsi.DATA{iSub} = Data_ROI.StimTargIpsi.LayerMean;
                    AllSubjects_Data(iROI).StimTargIpsi.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.StimTargIpsi.LayerMean, 2));

                    AllSubjects_Data(iROI).StimTargContra.DATA{iSub} = Data_ROI.StimTargContra.LayerMean;
                    AllSubjects_Data(iROI).StimTargContra.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.StimTargContra.LayerMean, 2));

                end

            else
                warning('The file %s does not exit.', File2Load);

                AllSubjects_Data(iROI).StimTargIpsi.DATA{iSub} = nan(NbLayers, 20, size(CondNames, 1));
                AllSubjects_Data(iROI).StimTargIpsi.grp(:, :, iSub) = nan(NbLayers, size(CondNames, 1));

                AllSubjects_Data(iROI).StimTargContra.DATA{iSub} = nan(NbLayers, 20, size(CondNames, 1));
                AllSubjects_Data(iROI).StimTargContra.grp(:, :, iSub) = nan(NbLayers, size(CondNames, 1));

            end

            clear Data_ROI;

        end
    end

    %% Averages over subjects
    for iROI = 1:length(AllSubjects_Data)

        fprintf(' Processing %s\n', AllSubjects_Data(iROI).name);

        AllSubjects_Data(iROI).StimTargIpsi.MEAN = nanmean(AllSubjects_Data(iROI).StimTargIpsi.grp(:, :, :), 3);
        AllSubjects_Data(iROI).StimTargIpsi.STD = nanstd(AllSubjects_Data(iROI).StimTargIpsi.grp(:, :, :), 3);
        AllSubjects_Data(iROI).StimTargIpsi.SEM = nansem(AllSubjects_Data(iROI).StimTargIpsi.grp(:, :, :), 3);

        AllSubjects_Data(iROI).StimTargContra.MEAN = nanmean(AllSubjects_Data(iROI).StimTargContra.grp(:, :, :), 3);
        AllSubjects_Data(iROI).StimTargContra.STD = nanstd(AllSubjects_Data(iROI).StimTargContra.grp(:, :, :), 3);
        AllSubjects_Data(iROI).StimTargContra.SEM = nansem(AllSubjects_Data(iROI).StimTargContra.grp(:, :, :), 3);

    end

    %% Betas from profile fits
    fprintf('\n');

    for iROI = 1:length(AllSubjects_Data)

        Name = AllSubjects_Data(iROI).name;

        fprintf('Computing betas for ROI %s\n', Name);

        for i = 1:2

            %% Actually compute betas
            for iSub = 1:NbSub

                switch i
                    case 1
                        Blocks = AllSubjects_Data(iROI).StimTargIpsi.DATA{iSub};
                    case 2
                        Blocks = AllSubjects_Data(iROI).StimTargContra.DATA{iSub};
                end

                if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

                    for iCond = 1:size(Blocks, 3)

                        Y = flipud(Blocks(:, :, iCond));
                        [B] = ProfileGLM(DesMat, Y);

                        switch i
                            case 1
                                AllSubjects_Data(iROI).StimTargIpsi.Beta.DATA(:, iCond, iSub) = B;
                            case 2
                                AllSubjects_Data(iROI).StimTargContra.Beta.DATA(:, iCond, iSub) = B;
                        end
                        clear Y B;

                    end

                end

            end

            %% Group stat on betas
            switch i
                case 1
                    tmp = AllSubjects_Data(iROI).StimTargIpsi.Beta.DATA(:, iCond, iSub);
                    AllSubjects_Data(iROI).StimTargIpsi.Beta.MEAN = nanmean(tmp, 3);
                    AllSubjects_Data(iROI).StimTargIpsi.Beta.STD = nanstd(tmp, 3);
                    AllSubjects_Data(iROI).StimTargIpsi.Beta.SEM = nansem(tmp, 3);
                case 2
                    tmp = AllSubjects_Data(iROI).StimTargContra.Beta.DATA(:, iCond, iSub);
                    AllSubjects_Data(iROI).StimTargContra.Beta.MEAN = nanmean(tmp, 3);
                    AllSubjects_Data(iROI).StimTargContra.Beta.STD = nanstd(tmp, 3);
                    AllSubjects_Data(iROI).StimTargContra.Beta.SEM = nansem(tmp, 3);
            end

            % T-Test
            for iCond = 1:size(tmp, 2)
                for BetaInd = 1:size(tmp, 1)
                    [~, P] = ttest(tmp(BetaInd, iCond, :));
                    switch i
                        case 1
                            AllSubjects_Data(iROI).StimTargIpsi.Beta.P(BetaInd, iCond) = P;
                        case 2
                            AllSubjects_Data(iROI).StimTargContra.Beta.P(BetaInd, iCond) = P;
                    end
                end
            end

            clear tmp P;

        end

    end

    %% Saves
    fprintf('\nSaving\n');

    for iROI = 1:numel(AllSubjects_Data)
        Results = AllSubjects_Data(iROI);
        save(fullfile(ResultsDir, strcat('Results_', AllSubjects_Data(iROI).name, ...
                                         '_VolStimsTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
    end

    save(fullfile(ResultsDir, strcat('ResultsVolStimsTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')));

    cd(StartDir);

end

function [B] = ProfileGLM(X, Y)

    if any(isnan(Y(:)))
        [~, y] = find(isnan(Y));
        y = unique(y);
        Y(:, y) = [];
        clear y;
    end

    if isempty(Y)
        B = nan(1, size(X, 2));
    else
        X = repmat(X, size(Y, 2), 1);
        Y = Y(:);
        [B, ~, ~] = glmfit(X, Y, 'normal', 'constant', 'off');
    end

end
