% (C) Copyright 2020 Remi Gau
function bold_vol_grp_avg
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
    ROIs = { ...
            'V1', ...
            'V2', ...
            'V3', ...
            'V4', ...
            'V5', ...
            'TE', ...
            'PT', ...
            'S1_aal', ...
            'S1_cyt'};

    for iROI = 1:length(ROIs)
        AllSubjects_Data(iROI) = struct( ...
                                        'name', ROIs{iROI});
    end

    %% Gets data for each subject
    for iSub = 1:NbSub

        SubDir = fullfile(StartDir, SubLs(iSub).name);
        SaveDir = fullfile(SubDir, 'results', 'profiles');

        for iROI = 1:numel(ROIs)

            File2Load = fullfile(SaveDir, strcat('Data_', AllSubjects_Data(iROI).name, '_l-', ...
                                                 num2str(NbLayers), '.mat'));

            if exist(File2Load, 'file')

                load(File2Load, 'Data_ROI');

                AllSubjects_Data(iROI).Cdt.grp(iSub, :) = nanmean(Data_ROI.WholeROI.MEAN);
                AllSubjects_Data(iROI).SensMod.grp(iSub, :) = nanmean(Data_ROI.SensMod.WholeROI.MEAN);
                AllSubjects_Data(iROI).ContSide.grp(iSub, :) = nanmean(Data_ROI.ContSide.WholeROI.MEAN);
                AllSubjects_Data(iROI).ContSensMod.grp(iSub, :) = nanmean(Data_ROI.ContSensMod.WholeROI.MEAN);

            else
                warning('The file %s does not exit.', File2Load);

                AllSubjects_Data(iROI).Cdt.grp(iSub, :) = nan(1, numel(CondNames));
                AllSubjects_Data(iROI).SensMod.grp(iSub, :) = nan(1, size(CondNames, 1));
                AllSubjects_Data(iROI).ContSide.grp(iSub, :) =  nan(1, size(CondNames, 1));
                AllSubjects_Data(iROI).ContSensMod.grp(iSub, :) = nan(1, 3);

            end

            clear Data_ROI;

        end
    end

    for iROI = 1:numel(ROIs)

        AllSubjects_Data(iROI).Cdt.MEAN = nanmean(AllSubjects_Data(iROI).Cdt.grp);
        AllSubjects_Data(iROI).Cdt.STD = nanstd(AllSubjects_Data(iROI).Cdt.grp);
        AllSubjects_Data(iROI).Cdt.SEM = nansem(AllSubjects_Data(iROI).Cdt.grp);

        AllSubjects_Data(iROI).SensMod.MEAN = nanmean(AllSubjects_Data(iROI).SensMod.grp);
        AllSubjects_Data(iROI).SensMod.STD = nanstd(AllSubjects_Data(iROI).SensMod.grp);
        AllSubjects_Data(iROI).SensMod.SEM = nansem(AllSubjects_Data(iROI).SensMod.grp);

        AllSubjects_Data(iROI).ContSide.MEAN = nanmean(AllSubjects_Data(iROI).ContSide.grp);
        AllSubjects_Data(iROI).ContSide.STD = nanstd(AllSubjects_Data(iROI).ContSide.grp);
        AllSubjects_Data(iROI).ContSide.SEM = nansem(AllSubjects_Data(iROI).ContSide.grp);

        AllSubjects_Data(iROI).ContSensMod.MEAN = nanmean(AllSubjects_Data(iROI).ContSensMod.grp);
        AllSubjects_Data(iROI).ContSensMod.STD = nanstd(AllSubjects_Data(iROI).ContSensMod.grp);
        AllSubjects_Data(iROI).ContSensMod.SEM = nansem(AllSubjects_Data(iROI).ContSensMod.grp);

    end

    %% Saves
    fprintf('\nSaving\n');

    save(fullfile(ResultsDir, strcat('ResultsVolBOLDWholeROI.mat')));

    cd(StartDir);

end
