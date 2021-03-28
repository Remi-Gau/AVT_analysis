function PlotBoldProfile()

    % see SetProfilePlottingOptions and CheckProfilePlottingOptions
    % in ``src/settings`` to change plotting options

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

    AgainstBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra);
    CrossSide(Data, ROIs, OutputDir, CondNamesIpsiContra);
    CrossSensory(Data, ROIs, OutputDir);
    Target_gt_Stim(Data, ROIs, OutputDir);
    CrosssideDifferenceWithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra);
    A_gt_T_WithBaseline(Data, OutputDir);
    V_gt_T_WithBaseline(Data, OutputDir);
    Target_gt_Stim_WithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra);

end

function AgainstBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra)

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

        Opt = SetProfilePlotParameters(Opt);

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'baseline'));

    end

end

function CrossSide(Data, ROIs, OutputDir, CondNamesIpsiContra)

    for Cdt = 2:2:12

        clear Opt;

        ToPlot = AllocateProfileData(Data, ROIs, {Cdt, -1 * (Cdt - 1)});

        Opt.Specific{1} = ToPlot;
        Opt.Specific{1}.Titles = '';
        Opt.Specific{1}.XLabel = ROIs;

        Opt.Title = ['[Contra-Ipsi]_{', ...
                     CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5), ...
                     '}'];

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crossside'));

    end

end

function CrossSensory(Data, ROIs, OutputDir)

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
        
        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crosssensory'));

    end

end

function Target_gt_Stim(Data, ROIs, OutputDir)

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

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'target-stim'));

    end

end

function CrosssideDifferenceWithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra)

    COLOR_MODALITIES = repmat(ModalityColors(), 2, 1);

    for Cdt = 2:2:12

        clear Opt;

        Opt.IsDifferencePlot = true();

        for iROI = 1:size(ROIs, 1)

            for iColumn = 1:2

                if iColumn == 1

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), {(Cdt - 1); Cdt});

                    Opt.Specific{1, iColumn} = ToPlot;
                    Opt.Specific{1, iColumn}.XLabel = { 'Ipsi', 'Contra'};

                    Opt.Specific{1, iColumn}.LineColors = [COLOR_MODALITIES(Cdt / 2, :) * 0.6
                                                           COLOR_MODALITIES(Cdt / 2, :)];

                elseif iColumn == 2

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt, -1 * (Cdt - 1)});

                    Opt.Specific{1, iColumn} = ToPlot;
                    Opt.Specific{1, iColumn}.XLabel = {'Contra - Ipsi'};

                end

                Opt.Specific{1, iColumn}.Titles = '';

            end

            Opt.Title = [ROIs{iROI} ' - [Contra-Ipsi]_{', ...
                         CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5), ...
                         '}'];

            PlotProfileAndBetas(Opt);
            PrintFigure(fullfile(OutputDir, 'crossside', ROIs{iROI}));

        end

    end

end

function A_gt_T_WithBaseline(Data, OutputDir) % in V1 and V2

    ROIs = {
            'V1'
            'V2'};

    COLOR_MODALITIES = ModalityColors();
    COLOR_MODALITIES(2, :) = []; % remove visual color

    Laterality = {'ipsi', 'contra'};

    Conditions = { ...
                  [1 5], [2 6]
                  [7 11], [8 12]
                 };

    for isTarget = 0:1

        clear Opt;

        Opt.IsDifferencePlot = true();

        for iROI = 1:size(ROIs, 1)

            for iLat = 1:2

                Color = COLOR_MODALITIES;
                if iLat == 1
                    Color = Color * 0.6;
                end

                for iColumn = 1:2

                    if iColumn == 1

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1); ...
                                                      Conditions{isTarget + 1, iLat}(2)});
                        Opt.Specific{1, iColumn} = ToPlot;

                        Opt.Specific{1, iColumn}.XLabel = {'Audio', 'Tactile'};

                        Opt.Specific{1, iColumn}.LineColors = Color;

                    elseif iColumn == 2

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1), ...
                                                      -1 * Conditions{isTarget + 1, iLat}(2)});
                        Opt.Specific{1, iColumn} = ToPlot;

                        Opt.Specific{1, iColumn}.XLabel = {'[Audio - Tactile]'};

                    end

                    Opt.Specific{1, iColumn}.Titles = '';

                end

                StimType = 'stim';
                if isTarget
                    StimType = 'target';
                end
                Opt.Title = [ROIs{iROI} ' - [A-T]_{' StimType '}_{ ; ' Laterality{iLat} '}'];

                PlotProfileAndBetas(Opt);
                PrintFigure(fullfile(OutputDir, 'crosssensory', ROIs{iROI}));

            end

        end
    end

end

function V_gt_T_WithBaseline(Data, OutputDir) % in A1 and PT
    % Plot stimuli [V-T] difference with contrast against baseline
    ROIs = {
            'A1'
            'PT'};

    COLOR_MODALITIES = ModalityColors();
    COLOR_MODALITIES(1, :) = []; % remove audio color

    Laterality = {'ipsi', 'contra'};

    Conditions = { ...
                  [3 5], [4 6]; ...
                  [9 11], [10 12] ...
                 };

    for isTarget = 0:1

        clear Opt;

        Opt.IsDifferencePlot = true();

        for iROI = 1:size(ROIs, 1)

            for iLat = 1:2

                Color = COLOR_MODALITIES;
                if iLat == 1
                    Color = Color * 0.6;
                end

                for iColumn = 1:2

                    if iColumn == 1

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1); ...
                                                      Conditions{isTarget + 1, iLat}(2)});
                        Opt.Specific{1, iColumn} = ToPlot;

                        Opt.Specific{1, iColumn}.XLabel = {'Visual', 'Tactile'};

                        Opt.Specific{1, iColumn}.LineColors = Color;

                    elseif iColumn == 2

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1), ...
                                                      -1 * Conditions{isTarget + 1, iLat}(2)});
                        Opt.Specific{1, iColumn} = ToPlot;

                        Opt.Specific{1, iColumn}.XLabel = {'[Visual - Tactile]'};

                    end

                    Opt.Specific{1, iColumn}.Titles = '';

                end

                StimType = 'stim';
                if isTarget
                    StimType = 'target';
                end
                Opt.Title = [ROIs{iROI} ' - [V-T]_{' StimType '}_{ ; ' Laterality{iLat} '}'];

                PlotProfileAndBetas(Opt);
                PrintFigure(fullfile(OutputDir, 'crosssensory', ROIs{iROI}));

            end

        end

    end

end

function Target_gt_Stim_WithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra)
    % Plot target-stim difference with contrast against baseline

    Laterality = {'ipsi', 'contra'};

    tmp = repmat(ModalityColors(), 2, 1);
    COLOR_MODALITIES = tmp([1 4 2 5 3 6], :);

    for Cdt = 1:2:6

        clear Opt;

        Opt.IsDifferencePlot = true();

        for iLat = 0:1

            for iROI = 1:size(ROIs, 1)

                for iColumn = 1:2

                    if iColumn == 1

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt + iLat; Cdt + iLat + 6});

                        Opt.Specific{1, iColumn} = ToPlot;
                        Opt.Specific{1, iColumn}.XLabel = {'Stim', 'Target'};

                        Opt.Specific{1, iColumn}.LineColors = [COLOR_MODALITIES(Cdt, :) * 0.6
                                                               COLOR_MODALITIES(Cdt, :)];

                    elseif iColumn == 2

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt + iLat + 6, -1 * (Cdt + iLat)});

                        Opt.Specific{1, iColumn} = ToPlot;
                        Opt.Specific{1, iColumn}.XLabel = {'Target - Stim'};

                    end

                    Opt.Specific{1, iColumn}.Titles = '';

                end

                Opt.Title = [ROIs{iROI} ' - [Target - Stim]_{', ...
                             CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5), ...
                             '}_{ ; ' Laterality{iLat + 1} '}'];

                PlotProfileAndBetas(Opt);
                PrintFigure(fullfile(OutputDir, 'target-stim', ROIs{iROI}));

            end

        end

    end

end
