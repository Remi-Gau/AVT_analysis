function bold_profiles_vol_grp_avg
    clc;
    clear;

    StartDir = fullfile(pwd, '..', '..');
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
                 'TStimL', 'TStimR'
                 %     'ATargL','ATargR';...
                 %     'VTargL','VTargR';...
                 %     'TTargL','TTargR';...
                };

    % ROI
    % ROIs= {...
    %     'V1',...
    %     'V2',...
    %     'V3',...
    %     'V4',...
    %     'V5',...
    %     'TE', ...
    %     'PT',...
    %     'S1_cyt',...
    %     'S1_aal',...
    %     'TE_L',...
    %     'PT_L',...
    %     'S1_L_cyt',...
    %     'S1_L_aal',...
    %     'V1_L',...
    %     'V2_L',...
    %     'V3_L',...
    %     'V4_L',...
    %     'V5_L',...
    %     'TE_R',...
    %     'PT_R',...
    %     'S1_R_cyt',...
    %     'S1_R_aal',...
    %     'V1_R',...
    %     'V2_R',...
    %     'V3_R',...
    %     'V4_R',...
    %     'V5_R'};

    ROIs = { ...
            'A1', ...
            'V1_thres', ...
            'V2_thres', ...
            'V3_thres', ...
            'V4_thres', ...
            'V5_thres', ...
            'PT', ...
            'A1_L', ...
            'V1_L_thres', ...
            'V2_L_thres', ...
            'V3_L_thres', ...
            'V4_L_thres', ...
            'V5_L_thres', ...
            'PT_L', ...
            'A1_R', ...
            'V1_R_thres', ...
            'V2_R_thres', ...
            'V3_R_thres', ...
            'V4_R_thres', ...
            'V5_R_thres', ...
            'PT_R'};

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

            File2Load = fullfile(SaveDir, strcat('Data_', AllSubjects_Data(iROI).name, '_l-', ...
                                                 num2str(NbLayers), '.mat'));

            if exist(File2Load, 'file')

                load(File2Load, 'Data_ROI');

                if Median

                    AllSubjects_Data(iROI).Cdt.DATA{iSub} = Data_ROI.LayerMedian;
                    AllSubjects_Data(iROI).Cdt.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.LayerMedian, 2));

                    AllSubjects_Data(iROI).SensMod.DATA{iSub} = Data_ROI.SensMod.LayerMedian;
                    AllSubjects_Data(iROI).SensMod.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.SensMod.LayerMedian, 2));

                    AllSubjects_Data(iROI).ContSide.DATA{iSub} = Data_ROI.ContSide.LayerMedian;
                    AllSubjects_Data(iROI).ContSide.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.ContSide.LayerMedian, 2));

                    AllSubjects_Data(iROI).ContSensMod.DATA{iSub} = Data_ROI.ContSensMod.LayerMedian;
                    AllSubjects_Data(iROI).ContSensMod.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.ContSensMod.LayerMedian, 2));

                else

                    AllSubjects_Data(iROI).Cdt.DATA{iSub} = Data_ROI.LayerMean;
                    AllSubjects_Data(iROI).Cdt.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.LayerMean, 2));

                    AllSubjects_Data(iROI).SensMod.DATA{iSub} = Data_ROI.SensMod.LayerMean;
                    AllSubjects_Data(iROI).SensMod.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.SensMod.LayerMean, 2));

                    AllSubjects_Data(iROI).ContSide.DATA{iSub} = Data_ROI.ContSide.LayerMean;
                    AllSubjects_Data(iROI).ContSide.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.ContSide.LayerMean, 2));

                    AllSubjects_Data(iROI).ContSensMod.DATA{iSub} = Data_ROI.ContSensMod.LayerMean;
                    AllSubjects_Data(iROI).ContSensMod.grp(:, :, iSub) = squeeze(nanmean(Data_ROI.ContSensMod.LayerMean, 2));

                end

            else
                warning('The file %s does not exit.', File2Load);

                AllSubjects_Data(iROI).Cdt.DATA{iSub} = nan(NbLayers, 20, numel(CondNames));
                AllSubjects_Data(iROI).Cdt.grp(:, :, iSub) = nan(NbLayers, numel(CondNames));

                AllSubjects_Data(iROI).SensMod.DATA{iSub} = nan(NbLayers, 20, size(CondNames, 1));
                AllSubjects_Data(iROI).SensMod.grp(:, :, iSub) = nan(NbLayers, size(CondNames, 1));

                AllSubjects_Data(iROI).ContSide.DATA{iSub} =  nan(NbLayers, 20, size(CondNames, 1));
                AllSubjects_Data(iROI).ContSide.grp(:, :, iSub) =  nan(NbLayers, size(CondNames, 1));

                AllSubjects_Data(iROI).ContSensMod.DATA{iSub} = nan(NbLayers, 20, 3);
                AllSubjects_Data(iROI).ContSensMod.grp(:, :, iSub) = nan(NbLayers, 3);

            end

            clear Data_ROI;

        end
    end

    %% Averages over subjects
    for iROI = 1:length(AllSubjects_Data)

        fprintf(' Processing %s\n', AllSubjects_Data(iROI).name);

        AllSubjects_Data(iROI).Cdt.MEAN = nanmean(AllSubjects_Data(iROI).Cdt.grp(:, :, :), 3);
        AllSubjects_Data(iROI).Cdt.STD = nanstd(AllSubjects_Data(iROI).Cdt.grp(:, :, :), 3);
        AllSubjects_Data(iROI).Cdt.SEM = nansem(AllSubjects_Data(iROI).Cdt.grp(:, :, :), 3);

        AllSubjects_Data(iROI).SensMod.MEAN = nanmean(AllSubjects_Data(iROI).SensMod.grp(:, :, :), 3);
        AllSubjects_Data(iROI).SensMod.STD = nanstd(AllSubjects_Data(iROI).SensMod.grp(:, :, :), 3);
        AllSubjects_Data(iROI).SensMod.SEM = nansem(AllSubjects_Data(iROI).SensMod.grp(:, :, :), 3);

        AllSubjects_Data(iROI).ContSide.MEAN = nanmean(AllSubjects_Data(iROI).ContSide.grp(:, :, :), 3);
        AllSubjects_Data(iROI).ContSide.STD = nanstd(AllSubjects_Data(iROI).ContSide.grp(:, :, :), 3);
        AllSubjects_Data(iROI).ContSide.SEM = nansem(AllSubjects_Data(iROI).ContSide.grp(:, :, :), 3);

        AllSubjects_Data(iROI).ContSensMod.MEAN = nanmean(AllSubjects_Data(iROI).ContSensMod.grp(:, :, :), 3);
        AllSubjects_Data(iROI).ContSensMod.STD = nanstd(AllSubjects_Data(iROI).ContSensMod.grp(:, :, :), 3);
        AllSubjects_Data(iROI).ContSensMod.SEM = nansem(AllSubjects_Data(iROI).ContSensMod.grp(:, :, :), 3);

    end

    %% Betas from profile fits
    fprintf('\n');

    DesMat = (1:NbLayers) - mean(1:NbLayers);

    DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
    % DesMat = [DesMat' ones(NbLayers,1)];

    DesMat = spm_orth(DesMat);

    for iROI = 1:length(AllSubjects_Data)

        Name = AllSubjects_Data(iROI).name;

        fprintf('Computing betas for ROI %s\n', Name);

        for i = 1:4

            %% Actually compute betas
            for iSub = 1:NbSub

                switch i
                    case 1
                        Blocks = AllSubjects_Data(iROI).Cdt.DATA{iSub};
                    case 2
                        Blocks = AllSubjects_Data(iROI).SensMod.DATA{iSub};
                    case 3
                        Blocks = AllSubjects_Data(iROI).ContSide.DATA{iSub};
                    case 4
                        Blocks = AllSubjects_Data(iROI).ContSensMod.DATA{iSub};
                end

                if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

                    for iCond = 1:size(Blocks, 3)

                        Y = flipud(Blocks(:, :, iCond));
                        [B] = ProfileGLM(DesMat, Y);

                        switch i
                            case 1
                                AllSubjects_Data(iROI).Cdt.Beta.DATA(:, iCond, iSub) = B;
                            case 2
                                AllSubjects_Data(iROI).SensMod.Beta.DATA(:, iCond, iSub) = B;
                            case 3
                                AllSubjects_Data(iROI).ContSide.Beta.DATA(:, iCond, iSub) = B;
                            case 4
                                AllSubjects_Data(iROI).ContSensMod.Beta.DATA(:, iCond, iSub) = B;
                        end
                        clear Y B;

                    end

                end

            end

            %% Group stat on betas
            switch i
                case 1
                    tmp = AllSubjects_Data(iROI).Cdt.Beta.DATA(:, iCond, iSub);
                    AllSubjects_Data(iROI).Cdt.Beta.MEAN = nanmean(tmp, 3);
                    AllSubjects_Data(iROI).Cdt.Beta.STD = nanstd(tmp, 3);
                    AllSubjects_Data(iROI).Cdt.Beta.SEM = nansem(tmp, 3);
                case 2
                    tmp = AllSubjects_Data(iROI).SensMod.Beta.DATA(:, iCond, iSub);
                    AllSubjects_Data(iROI).SensMod.Beta.MEAN = nanmean(tmp, 3);
                    AllSubjects_Data(iROI).SensMod.Beta.STD = nanstd(tmp, 3);
                    AllSubjects_Data(iROI).SensMod.Beta.SEM = nansem(tmp, 3);
                case 3
                    tmp = AllSubjects_Data(iROI).ContSide.Beta.DATA(:, iCond, iSub);
                    AllSubjects_Data(iROI).ContSide.Beta.MEAN = nanmean(tmp, 3);
                    AllSubjects_Data(iROI).ContSide.Beta.STD = nanstd(tmp, 3);
                    AllSubjects_Data(iROI).ContSide.Beta.SEM = nansem(tmp, 3);
                case 4
                    tmp = AllSubjects_Data(iROI).ContSensMod.Beta.DATA(:, iCond, iSub);
                    AllSubjects_Data(iROI).ContSensMod.Beta.MEAN = nanmean(tmp, 3);
                    AllSubjects_Data(iROI).ContSensMod.Beta.STD = nanstd(tmp, 3);
                    AllSubjects_Data(iROI).ContSensMod.Beta.SEM = nansem(tmp, 3);
            end

            % T-Test
            for iCond = 1:size(tmp, 2)
                for BetaInd = 1:size(tmp, 1)
                    [~, P] = ttest(tmp(BetaInd, iCond, :));
                    switch i
                        case 1
                            AllSubjects_Data(iROI).Cdt.Beta.P(BetaInd, iCond) = P;
                        case 2
                            AllSubjects_Data(iROI).SensMod.Beta.P(BetaInd, iCond) = P;
                        case 3
                            AllSubjects_Data(iROI).ContSide.Beta.P(BetaInd, iCond) = P;
                        case 4
                            AllSubjects_Data(iROI).ContSensMod.Beta.P(BetaInd, iCond) = P;
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
                                         '_VolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
    end

    save(fullfile(ResultsDir, strcat('ResultsVolQuadGLM_l-', num2str(NbLayers), '.mat')));

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
