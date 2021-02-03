%% PlotBoldProfile

clear;
close all;

space = 'surf';
MVNN =  false;

[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');
OutputDir = fullfile(Dirs.Figures, 'BoldProfiles');
[~, ~, ~] = mkdir(OutputDir);

%     ConditionType = 'stim';
%     if IsTarget
%         ConditionType = 'target'; %#ok<*UNRCH>
%     end

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

    for iColumn = 1:2

        if iColumn == 2
            Cdt = Cdt + 1;
        end

        ToPlot = AllocateProfileData(Data, ROIs, {Cdt});

        Opt.Specific{1, iColumn} = ToPlot;
        Opt.Specific{1, iColumn}.Titles = CondNamesIpsiContra{Cdt}(6:end);
        Opt.Specific{1, iColumn}.XLabel = ROIs;

    end

    Opt.Title = strrep(CondNamesIpsiContra{Cdt}(1:5), 'S', ' S');

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);
    PrintFigure(fullfile(OutputDir, 'baseline'));

end

%% Cross side for stimuli

for Cdt = 2:2:6

    clear Opt;

    ToPlot = AllocateProfileData(Data, ROIs, {Cdt, -1 * (Cdt - 1)});

    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = '';
    Opt.Specific{1}.XLabel = ROIs;

    Opt.Title = ['[Contra-Ipsi]_{' CondNamesIpsiContra{Cdt}(1) '}'];

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);
    PrintFigure(fullfile(OutputDir, 'crossside'));

end

%% Cross stimuli sensory

Comparisons = {
               [1, -5], [2, -6]
               [3, -5], [4, -6]};

ComparisonsNames = {'[A-T]', '[V-T]'};
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

%% Plot stimuli crossside difference with contrast against baseline
ROIs = {
        'A1'
        'PT'
        'V1'
        'V2'};

COLOR_MODALITIES = ModalityColours();

for Cdt = 2:2:6

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
        Opt.Title = [ROIs{iROI} ' - [Contra-Ipsi]_{' CondNamesIpsiContra{Cdt}(1) '}'];

        Opt = SetProfilePlottingOptions(Opt);

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crossside'));

    end

end

%% Plot stimuli [A-T] difference with contrast against baseline in V1 and V2
ROIs = {
        'V1'
        'V2'};

COLOR_MODALITIES = ModalityColours();
COLOR_MODALITIES(2, :) = []; % remove visual color

Laterality = {'ipsi', 'contra'};

Conditions = {[1 5], [2 6]};

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
                                             {Conditions{1, iLat}(1); Conditions{1, iLat}(2)});
                Opt.Specific{1, iColumn} = ToPlot;

                Opt.Specific{1, iColumn}.XLabel = {'Audio', 'Tactile'};

                Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};
                Opt.Specific{1, iColumn}.LineColors = Color;

            elseif iColumn == 2

                ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                             {Conditions{1, iLat}(1), -1 * Conditions{1, iLat}(2)});
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
        Opt.Title = [ROIs{iROI} ' - [A-T]_{' Laterality{iLat} '}'];

        Opt = SetProfilePlottingOptions(Opt);

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crosssensory'));

    end

end

%% Plot stimuli [V-T] difference with contrast against baseline in A1 and PT
ROIs = {
        'A1'
        'PT'};

COLOR_MODALITIES = ModalityColours();
COLOR_MODALITIES(1, :) = []; % remove audio color

Laterality = {'ipsi', 'contra'};

Conditions = {[3 5], [4 6]};

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
                                             {Conditions{1, iLat}(1); Conditions{1, iLat}(2)});
                Opt.Specific{1, iColumn} = ToPlot;

                Opt.Specific{1, iColumn}.XLabel = {'Visual', 'Tactile'};

                Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};
                Opt.Specific{1, iColumn}.LineColors = Color;

            elseif iColumn == 2

                ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                             {Conditions{1, iLat}(1), -1 * Conditions{1, iLat}(2)});
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
        Opt.Title = [ROIs{iROI} ' - [V-T]_{' Laterality{iLat} '}'];

        Opt = SetProfilePlottingOptions(Opt);

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crosssensory'));

    end

end
