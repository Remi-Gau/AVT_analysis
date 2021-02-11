%% PlotBoldProfile

clc;
clear;
close all;

space = 'surf';
MVNN =  false;

[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');
OutputDir = fullfile(Dirs.Figures, 'BoldProfiles');
[~, ~, ~] = mkdir(OutputDir);

ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

Data = LoadProfileData(ROIs, InputDir);

[~, CondNamesIpsiContra] = GetConditionList();

%% Against baseline
ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

for Cdt = 1:2:11

    clear Opt;

    ThisCdt = Cdt;

    for iColumn = 1:2

        if iColumn == 2
            ThisCdt = Cdt + 1;
        end

        ToPlot = AllocateProfileData(Data, ROIs, {ThisCdt});

        Opt.Specific{1, iColumn} = ToPlot;
        Opt.Specific{1, iColumn}.Titles = CondNamesIpsiContra{ThisCdt}(6:end);
        Opt.Specific{1, iColumn}.XLabel = ROIs;
        Opt.Specific{1, iColumn}.PlotMinMaxType = 'groupallcolumns';

    end

    Opt.Title = [CondNamesIpsiContra{ThisCdt}(1) ' ' CondNamesIpsiContra{ThisCdt}(2:5)];

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);
    PrintFigure(fullfile(OutputDir, 'baseline'));

end

%% Cross side comparison

for Cdt = 2:2:12

    clear Opt;

    ToPlot = AllocateProfileData(Data, ROIs, {Cdt, -1 * (Cdt - 1)});

    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = '';
    Opt.Specific{1}.XLabel = ROIs;

    Opt.Title = ['[Contra-Ipsi]_{', ...
                 CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5), ...
                 '}'];

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);
    PrintFigure(fullfile(OutputDir, 'crossside'));

end

%% Cross sensory

Comparisons = {
               [1, -5], [2, -6]
               [3, -5], [4, -6]
               [7, -11], [8, -12]
               [9, -5], [10, -12]
              };

ComparisonsNames = {'[A-T]_{stim}', '[V-T]_{stim}' '[A-T]_{target}', '[V-T]_{target}'};
ColumnNames = {'ipsi', 'contra'};

for iComp = 1:size(Comparisons, 1)

    clear Opt;

    for iColumn = 1:2

        tmp = {Comparisons{iComp, iColumn}(1), Comparisons{iComp, iColumn}(2)};

        ToPlot = AllocateProfileData(Data, ROIs, tmp);

        Opt.Specific{1, iColumn} = ToPlot;
        Opt.Specific{1, iColumn}.Titles = ColumnNames{iColumn};
        Opt.Specific{1, iColumn}.XLabel = ROIs;

    end

    Opt.Title = ComparisonsNames{iComp};

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);
    PrintFigure(fullfile(OutputDir, 'crosssensory'));

end

%% target - stim

Comparisons = {
               [7, -1], [8, -2]
               [9, -3], [10, -4]
               [11, -5], [12, -6]
              };

ComparisonsNames = {'Audio', 'Visual' 'Tactile'};
ColumnNames = {'ipsi', 'contra'};

for iComp = 1:size(Comparisons, 1)

    clear Opt;

    for iColumn = 1:2

        tmp = {Comparisons{iComp, iColumn}(1), Comparisons{iComp, iColumn}(2)};

        ToPlot = AllocateProfileData(Data, ROIs, tmp);

        Opt.Specific{1, iColumn} = ToPlot;
        Opt.Specific{1, iColumn}.Titles = ColumnNames{iColumn};
        Opt.Specific{1, iColumn}.XLabel = ROIs;

    end

    Opt.Title = ['Target-Stim_{' ComparisonsNames{iComp} '}'];

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);
    PrintFigure(fullfile(OutputDir, 'target-stim'));

end

%% Plot crossside difference with contrast against baseline
ROIs = {
        'A1'
        'PT'
        'V1'
        'V2'};

COLOR_MODALITIES = repmat(ModalityColours(), 2, 1);

for Cdt = 2:2:12

    for iROI = 1:size(ROIs, 1)

        clear Opt;

        for iColumn = 1:2

            if iColumn == 1

                ToPlot = AllocateProfileData(Data, ROIs(iROI), {(Cdt - 1); Cdt});

                Opt.Specific{1, iColumn} = ToPlot;
                Opt.Specific{1, iColumn}.XLabel = { 'Ipsi', 'Contra'};

                Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};
                Opt.Specific{1, iColumn}.LineColors = [COLOR_MODALITIES(Cdt / 2, :) * 0.6
                                                       COLOR_MODALITIES(Cdt / 2, :)];

            elseif iColumn == 2

                ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt, -1 * (Cdt - 1)});

                Opt.Specific{1, iColumn} = ToPlot;
                Opt.Specific{1, iColumn}.XLabel = {'Contra - Ipsi'};

                Opt.Specific{1, iColumn}.ProfileSubplot = 5:8;
                Opt.Specific{1, iColumn}.BetaSubplot = {10; 12; 14};
                Opt.Specific{1, iColumn}.LineColors = [127 127 127] / 256;

            end

            Opt.Specific{1, iColumn}.Titles = '';

        end

        Opt.m = 2;
        Opt.n = 5;
        Opt.Title = [ROIs{iROI} ' - [Contra-Ipsi]_{', ...
                     CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5), ...
                     '}'];

        Opt = SetProfilePlottingOptions(Opt);

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crossside'));

    end

end

%% Plot [A-T] difference with contrast against baseline in V1 and V2
ROIs = {
        'V1'
        'V2'};

COLOR_MODALITIES = ModalityColours();
COLOR_MODALITIES(2, :) = []; % remove visual color

Laterality = {'ipsi', 'contra'};

Conditions = { ...
              [1 5], [2 6]
              [7 11], [8 12]
             };

for isTarget = 0:1

    for iROI = 1:size(ROIs, 1)

        for iLat = 1:2

            Color = COLOR_MODALITIES;
            if iLat == 1
                Color = Color * 0.6;
            end

            clear Opt;

            for iColumn = 1:2

                if iColumn == 1

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                 {Conditions{isTarget + 1, iLat}(1); ...
                                                  Conditions{isTarget + 1, iLat}(2)});
                    Opt.Specific{1, iColumn} = ToPlot;

                    Opt.Specific{1, iColumn}.XLabel = {'Audio', 'Tactile'};

                    Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                    Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};
                    Opt.Specific{1, iColumn}.LineColors = Color;

                elseif iColumn == 2

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                 {Conditions{isTarget + 1, iLat}(1), ...
                                                  -1 * Conditions{isTarget + 1, iLat}(2)});
                    Opt.Specific{1, iColumn} = ToPlot;

                    Opt.Specific{1, iColumn}.XLabel = {'[Audio - Tactile]'};

                    Opt.Specific{1, iColumn}.ProfileSubplot = 5:8;
                    Opt.Specific{1, iColumn}.BetaSubplot = {10; 12; 14};
                    Opt.Specific{1, iColumn}.LineColors = [127 127 127] / 256;

                end

                Opt.Specific{1, iColumn}.Titles = '';

            end

            Opt.m = 2;
            Opt.n = 5;
            StimType = 'stim';
            if isTarget
                StimType = 'target';
            end
            Opt.Title = [ROIs{iROI} ' - [A-T]_{' StimType '}_{ ; ' Laterality{iLat} '}'];

            Opt = SetProfilePlottingOptions(Opt);

            PlotProfileAndBetas(Opt);
            PrintFigure(fullfile(OutputDir, 'crosssensory'));

        end

    end
end

%% Plot stimuli [V-T] difference with contrast against baseline in A1 and PT
ROIs = {
        'A1'
        'PT'};

COLOR_MODALITIES = ModalityColours();
COLOR_MODALITIES(1, :) = []; % remove audio color

Laterality = {'ipsi', 'contra'};

Conditions = { ...
              [3 5], [4 6]; ...
              [9 11], [10 12] ...
             };

for isTarget = 0:1

    for iROI = 1:size(ROIs, 1)

        for iLat = 1:2

            Color = COLOR_MODALITIES;
            if iLat == 1
                Color = Color * 0.6;
            end

            clear Opt;

            for iColumn = 1:2

                if iColumn == 1

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                 {Conditions{isTarget + 1, iLat}(1); ...
                                                  Conditions{isTarget + 1, iLat}(2)});
                    Opt.Specific{1, iColumn} = ToPlot;

                    Opt.Specific{1, iColumn}.XLabel = {'Visual', 'Tactile'};

                    Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                    Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};
                    Opt.Specific{1, iColumn}.LineColors = Color;

                elseif iColumn == 2

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                 {Conditions{isTarget + 1, iLat}(1), ...
                                                  -1 * Conditions{isTarget + 1, iLat}(2)});
                    Opt.Specific{1, iColumn} = ToPlot;

                    Opt.Specific{1, iColumn}.XLabel = {'[Visual - Tactile]'};

                    Opt.Specific{1, iColumn}.ProfileSubplot = 5:8;
                    Opt.Specific{1, iColumn}.BetaSubplot = {10; 12; 14};
                    Opt.Specific{1, iColumn}.LineColors = [127 127 127] / 256;

                end

                Opt.Specific{1, iColumn}.Titles = '';

            end

            Opt.m = 2;
            Opt.n = 5;
            StimType = 'stim';
            if isTarget
                StimType = 'target';
            end
            Opt.Title = [ROIs{iROI} ' - [V-T]_{' StimType '}_{ ; ' Laterality{iLat} '}'];

            Opt = SetProfilePlottingOptions(Opt);

            PlotProfileAndBetas(Opt);
            PrintFigure(fullfile(OutputDir, 'crosssensory'));

        end

    end

end

%% Plot target-stim difference with contrast against baseline
ROIs = {
        'A1'
        'PT'
        'V1'
        'V2'};

Laterality = {'ipsi', 'contra'};

tmp = repmat(ModalityColours(), 2, 1);
COLOR_MODALITIES = tmp([1 4 2 5 3 6],:);

for Cdt = 1:2:6

    for iLat = 0:1

        for iROI = 1:size(ROIs, 1)

            clear Opt;

            for iColumn = 1:2

                if iColumn == 1

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt + iLat; Cdt + iLat + 6});

                    Opt.Specific{1, iColumn} = ToPlot;
                    Opt.Specific{1, iColumn}.XLabel = {'Stim', 'Target'};

                    Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                    Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};
                    Opt.Specific{1, iColumn}.LineColors = [COLOR_MODALITIES(Cdt, :) * 0.6
                                                           COLOR_MODALITIES(Cdt, :)];

                elseif iColumn == 2

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt + iLat + 6, -1 * (Cdt + iLat)});

                    Opt.Specific{1, iColumn} = ToPlot;
                    Opt.Specific{1, iColumn}.XLabel = {'Target - Stim'};

                    Opt.Specific{1, iColumn}.ProfileSubplot = 5:8;
                    Opt.Specific{1, iColumn}.BetaSubplot = {10; 12; 14};
                    Opt.Specific{1, iColumn}.LineColors = [127 127 127] / 256;

                end

                Opt.Specific{1, iColumn}.Titles = '';

            end

            Opt.m = 2;
            Opt.n = 5;
            Opt.Title = [ROIs{iROI} ' - [Target - Stim]_{', ...
                         CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5), ...
                         '}_{ ; ' Laterality{iLat + 1} '}'];

            Opt = SetProfilePlottingOptions(Opt);

            PlotProfileAndBetas(Opt);
            PrintFigure(fullfile(OutputDir, 'target-stim'));

        end

    end

end
