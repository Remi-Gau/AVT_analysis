% see ``src/settings`` 
% and ``lib/laminar_tools/src/settings`` 
% to change plotting options

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

Opt = SetDefaults();

Data = LoadProfileData(Opt, ROIs, InputDir);

[~, CondNamesIpsiContra] = GetConditionList();

%%
% AgainstBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra);
% CrossSide(Data, ROIs, OutputDir, CondNamesIpsiContra);
% CrossSensory(Data, ROIs, OutputDir);
% Target_gt_Stim(Data, ROIs, OutputDir);

%% the following won't work if you try to plot the quadratic component
% CrosssideDifferenceWithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra);
% A_gt_T_WithBaseline(Data, OutputDir); % in V1 and V2
V_gt_T_WithBaseline(Data, OutputDir); % in A1 and PT
Target_gt_Stim_WithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra);

%%
function AgainstBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra)

    Opt = SetDefaults();
    
    NbColumns = 2;
    if Opt.PoolIpsiContra
        NbColumns = 1;
    end
    
    for Cdt = 1:2:11

        ThisCdt = Cdt;
        
        for iColumn = 1:NbColumns

            if iColumn == 2
                ThisCdt = Cdt + 1;
            end

            ToPlot = AllocateProfileData(Data, ROIs, {ThisCdt});
            ToPlot.PlotMinMaxType = 'groupallcolumns';

            if ~Opt.PoolIpsiContra
                ToPlot.Titles = CondNamesIpsiContra{ThisCdt}(6:end);
            end
            
            Opt.Specific{1, iColumn} = ToPlot;

        end

        Opt.Title = [CondNamesIpsiContra{ThisCdt}(1) ' ' CondNamesIpsiContra{ThisCdt}(2:5)];

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'baseline'));

    end

end

function CrossSide(Data, ROIs, OutputDir, CondNamesIpsiContra)
    
    Opt = SetDefaults();
    if Opt.PoolIpsiContra
        warning('Opt.PoolIpsiContra set to true: no contra-ipsi figure will be generated.')
        return
    end
    

    for Cdt = 2:2:12

        Opt.Specific{1} = AllocateProfileData(Data, ROIs, {Cdt, -1 * (Cdt - 1)});

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

    ComparisonsNames = {...
        '[A-T]_{stim}'; ...
        '[V-T]_{stim}'; ...
        '[A-T]_{target}'; ...
        '[V-T]_{target}'};
   
    for iComp = 1:size(Comparisons, 1)

        Opt = SetUpComparisonPlot(Data, ROIs, Comparisons, iComp);
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
    
    for iComp = 1:size(Comparisons, 1)

        Opt = SetUpComparisonPlot(Data, ROIs, Comparisons, iComp);
        Opt.Title = ['Target-Stim_{' ComparisonsNames{iComp} '}'];

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'target-stim'));

    end

end

function CrosssideDifferenceWithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra)

    Opt = SetDefaults();
    if Opt.PoolIpsiContra
        warning('Opt.PoolIpsiContra set to true: no contra-ipsi figure will be generated.')
        return
    end
    
    COLOR_MODALITIES = repmat(ModalityColors(), 2, 1);

    for Cdt = 2:2:12

        Opt.IsDifferencePlot = true();

        for iROI = 1:size(ROIs, 1)

            for iColumn = 1:2

                if iColumn == 1

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), {(Cdt - 1); Cdt});
                    ToPlot.XLabel = { 'Ipsi', 'Contra'};
                    ToPlot.LineColors = [COLOR_MODALITIES(Cdt / 2, :) * 0.6
                                                           COLOR_MODALITIES(Cdt / 2, :)];

                elseif iColumn == 2

                    ToPlot = AllocateProfileData(Data, ROIs(iROI), {Cdt, -1 * (Cdt - 1)});
                    ToPlot.XLabel = {'Contra - Ipsi'};

                end
                
                Opt.Specific{1, iColumn} = ToPlot;
                

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

    Opt = SetDefaults();
    Opt.IsDifferencePlot = true();
    
    Laterality = {'ipsi', 'contra'};
    if Opt.PoolIpsiContra
        Laterality = {''};
    end

    Conditions = { ...
                  [1 5], [2 6]
                  [7 11], [8 12]
                 };

    for isTarget = 0:1

        for iROI = 1:size(ROIs, 1)

            for iLat = 1:size(Laterality, 2)

                Color = COLOR_MODALITIES;
                if iLat == 2
                    Color = Color * 0.6;
                end

                for iColumn = 1:2

                    if iColumn == 1

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1); ...
                                                      Conditions{isTarget + 1, iLat}(2)});
                        ToPlot.XLabel = {'Audio', 'Tactile'};
                        ToPlot.LineColors = Color;

                    elseif iColumn == 2

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1), ...
                                                      -1 * Conditions{isTarget + 1, iLat}(2)});
                        ToPlot.XLabel = {'[Audio - Tactile]'};

                    end

                    Opt.Specific{1, iColumn} = ToPlot;

                end

                StimType = 'stim';
                if isTarget
                    StimType = 'target';
                end
                
                Opt.Title = [ROIs{iROI} ' - [A-T]_{' StimType '}'];
                if ~Opt.PoolIpsiContra
                    Opt.Title = [Opt.Title '_{ ; ' Laterality{iLat} '}'];
                end

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

    Opt = SetDefaults();
    Opt.IsDifferencePlot = true();
    
    Laterality = {'ipsi', 'contra'};
    if Opt.PoolIpsiContra
        Laterality = {''};
    end

    Conditions = { ...
                  [3 5], [4 6]; ...
                  [9 11], [10 12] ...
                 };

    for isTarget = 0:1

        for iROI = 1:size(ROIs, 1)

            for iLat = 1:size(Laterality, 2)

                Color = COLOR_MODALITIES;
                if iLat == 2
                    Color = Color * 0.6;
                end

                for iColumn = 1:2

                    if iColumn == 1

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1); ...
                                                      Conditions{isTarget + 1, iLat}(2)});
                        ToPlot.XLabel = {'Visual', 'Tactile'};
                        ToPlot.LineColors = Color;

                    elseif iColumn == 2

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Conditions{isTarget + 1, iLat}(1), ...
                                                      -1 * Conditions{isTarget + 1, iLat}(2)});
                        ToPlot.XLabel = {'[Visual - Tactile]'};

                    end

                    Opt.Specific{1, iColumn} = ToPlot;

                end

                StimType = 'stim';
                if isTarget
                    StimType = 'target';
                end

                Opt.Title = [ROIs{iROI} ' - [V-T]_{' StimType '}'];
                if ~Opt.PoolIpsiContra
                    Opt.Title = [Opt.Title '_{ ; ' Laterality{iLat} '}'];
                end
                

                PlotProfileAndBetas(Opt);
                PrintFigure(fullfile(OutputDir, 'crosssensory', ROIs{iROI}));

            end

        end

    end

end

function Target_gt_Stim_WithBaseline(Data, ROIs, OutputDir, CondNamesIpsiContra)
    % Plot target-stim difference with contrast against baseline

    tmp = repmat(ModalityColors(), 2, 1);
    COLOR_MODALITIES = tmp([1 4 2 5 3 6], :);
    
    Opt = SetDefaults();
    Opt.IsDifferencePlot = true();
    
    Laterality = {'ipsi', 'contra'};
    if Opt.PoolIpsiContra
        Laterality = {''};
    end

    for Cdt = 1:2:6

        for iLat = 0:(size(Laterality, 2) - 1)

            for iROI = 1:size(ROIs, 1)

                for iColumn = 1:2

                    if iColumn == 1

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Cdt + iLat; Cdt + iLat + 6});
                        ToPlot.XLabel = {'Stim', 'Target'};
                        ToPlot.LineColors = [COLOR_MODALITIES(Cdt, :) * 0.6
                                             COLOR_MODALITIES(Cdt, :)];

                    elseif iColumn == 2

                        ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                                     {Cdt + iLat + 6, -1 * (Cdt + iLat)});
                        ToPlot.XLabel = {'Target - Stim'};

                    end

                    Opt.Specific{1, iColumn} = ToPlot;

                end

                Opt.Title = [ROIs{iROI} ' - [Target - Stim]_{', ...
                             CondNamesIpsiContra{Cdt}(1) ' ' CondNamesIpsiContra{Cdt}(2:5) '}'];
                if ~Opt.PoolIpsiContra
                    Opt.Title = [Opt.Title '_{ ; ' Laterality{iLat} '}'];
                end                         

                PlotProfileAndBetas(Opt);
                PrintFigure(fullfile(OutputDir, 'target-stim', ROIs{iROI}));

            end

        end

    end

end

%%

function Opt = SetUpComparisonPlot(Data, ROIs, Comparisons, iComp)
    
    Opt = SetDefaults();
    
    ColumnNames = {'ipsi', 'contra'};
    if Opt.PoolIpsiContra
        ColumnNames = {''};
    end

    for iColumn = 1:size(ColumnNames, 2)
        
        tmp = {Comparisons{iComp, iColumn}(1), Comparisons{iComp, iColumn}(2)};
        
        ToPlot = AllocateProfileData(Data, ROIs, tmp);
        ToPlot.Titles = ColumnNames{iColumn};
        
        Opt.Specific{1, iColumn} = ToPlot;
        
    end
    
end