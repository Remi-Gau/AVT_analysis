% PlotBoldProfile

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

%% Against baseline
ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

[~, CondNamesIpsiContra] = GetConditionList();

for iROI = 2:2:6

    clear Opt;

    for iColumn = 1:2

        if iColumn == 2
            iROI = iROI - 1;
        end

        ToPlot = AllocateProfileData(Data, ROIs, {iROI});

        Opt.Specific{1, iColumn} = ToPlot;
        Opt.Specific{1, iColumn}.Titles = CondNamesIpsiContra{iROI}(6:end);
        Opt.Specific{1, iColumn}.XLabel = ROIs;

    end

    Opt.Title = strrep(CondNamesIpsiContra{iROI}(1:5), 'S', ' S');

    Opt = SetProfilePlottingOptions(Opt);

    %     PlotProfileAndBetas(Opt);
    %     PrintFigure(fullfile(OutputDir, 'baseline'));

end

%% Cross side

for iROI = 2:2:6

    clear Opt;

    ToPlot = AllocateProfileData(Data, ROIs, {iROI, -1 * (iROI - 1)});

    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = '';
    Opt.Specific{1}.XLabel = ROIs;

    Opt.Title = ['[Contra-Ipsi]_{' CondNamesIpsiContra{iROI}(1) '}'];

    Opt = SetProfilePlottingOptions(Opt);

    %     PlotProfileAndBetas(Opt);
    %     PrintFigure(fullfile(OutputDir, 'crossside'));

end

%% Cross sensory

Comparisons = {
               [2, -6], [1, -5]
               [4, -6], [3, -5]};

ComparisonsNames = {'[A-T]', '[V-T]'};
ColumnNames = {'contra', 'ipsi'};

for iROI = 1:size(Comparisons, 1)

    clear Opt;

    for iColumn = 1:2

        tmp = {Comparisons{iROI, iColumn}(1), Comparisons{iROI, iColumn}(2)};

        ToPlot = AllocateProfileData(Data, ROIs, tmp);

        Opt.Specific{1, iColumn} = ToPlot;
        Opt.Specific{1, iColumn}.Titles = ColumnNames{iColumn};
        Opt.Specific{1, iColumn}.XLabel = ROIs;

    end

    Opt.Title = ComparisonsNames{iROI};

    Opt = SetProfilePlottingOptions(Opt);

    %     PlotProfileAndBetas(Opt);
    %     PrintFigure(fullfile(OutputDir, 'crosssensory'));

end

%% Plot crossside difference with contrast against baseline
ROIs = {
        'PT'
        'V2'};

for iROI = 1:size(ROIs, 1)

    clear Opt;

    for iColumn = 1:2

        if iColumn == 1

            ToPlot = AllocateProfileData(Data, ROIs(iROI), {6; 5});

            Opt.Specific{1, iColumn} = ToPlot;
            Opt.Specific{1, iColumn}.Titles = 'contra & ipsi';
            Opt.Specific{1, iColumn}.XLabel = {'contra', 'ipsi'};

            Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
            Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};

        elseif iColumn == 2

            ToPlot = AllocateProfileData(Data, ROIs(iROI), {6, -5});

            Opt.Specific{1, iColumn} = ToPlot;
            Opt.Specific{1, iColumn}.Titles = 'difference';
            Opt.Specific{1, iColumn}.XLabel = {'difference'};

            Opt.Specific{1, iColumn}.ProfileSubplot = 5:8;
            Opt.Specific{1, iColumn}.BetaSubplot = {10; 12; 14};
            Opt.Specific{1, iColumn}.LineColors = [127 127 127] / 256;

        end

    end

    Opt.m = 2;
    Opt.n = 5;
    Opt.Title = [ROIs{iROI} ' - [Contra-Ipsi]_T'];

    Opt = SetProfilePlottingOptions(Opt);

    %     PlotProfileAndBetas(Opt);
    %     PrintFigure(fullfile(OutputDir, 'crossside'));

end

%% Plot [A-T] difference with contrast against baseline
ROIs = {
        'V1'
        'V2'};

Laterality = {'ipsi', 'contra'};

Conditions = {[1 5], [2 6]};

for iROI = 1:size(ROIs, 1)

    for iLat = 1:2

        clear Opt;

        for iColumn = 1:2

            if iColumn == 1

                ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                             {Conditions{1, iLat}(1); Conditions{1, iLat}(2)});

                Opt.Specific{1, iColumn} = ToPlot;
                Opt.Specific{1, iColumn}.Titles = ['[A-T]_{' Laterality{iLat} '}'];
                Opt.Specific{1, iColumn}.XLabel = {'audio', 'tactile'};

                Opt.Specific{1, iColumn}.ProfileSubplot = 1:4;
                Opt.Specific{1, iColumn}.BetaSubplot = {9; 11; 13};

            elseif iColumn == 2

                ToPlot = AllocateProfileData(Data, ROIs(iROI), ...
                                             {Conditions{1, iLat}(1), -1 * Conditions{1, iLat}(2)});

                Opt.Specific{1, iColumn} = ToPlot;
                Opt.Specific{1, iColumn}.Titles = ['difference_{' Laterality{iLat} '}'];
                Opt.Specific{1, iColumn}.XLabel = {'difference'};

                Opt.Specific{1, iColumn}.ProfileSubplot = 5:8;
                Opt.Specific{1, iColumn}.BetaSubplot = {10; 12; 14};
                Opt.Specific{1, iColumn}.LineColors = [127 127 127] / 256;

            end

        end

        Opt.m = 2;
        Opt.n = 5;
        Opt.Title = [ROIs{iROI} ' - [A-T]_{' Laterality{iLat} '}'];

        Opt = SetProfilePlottingOptions(Opt);

        PlotProfileAndBetas(Opt);
        PrintFigure(fullfile(OutputDir, 'crosssensory'));

    end

end
