function PlotBoldProfile

    clear;
    close all;

    ROIs = { ...
            'A1'
            'PT'
            'V1'
            'V2'
           };

    space = 'surf';

    %%
    MVNN =  false;
    [Dirs] = SetDir(space, MVNN);
    InputDir = fullfile(Dirs.ExtractedBetas, 'group');
    OutputDir = fullfile(Dirs.Figures, 'BoldProfiles');
    mkdir(OutputDir);

    %     ConditionType = 'stim';
    %     if IsTarget
    %         ConditionType = 'target'; %#ok<*UNRCH>
    %     end

    Data = LoadData(ROIs, InputDir);

    [~, CondNamesIpsiContra] = GetConditionList();

    for Cdt = 1:6
        AllocateDataAndPlot(Data, ROIs, CondNamesIpsiContra{Cdt}, {Cdt});
        PrintFigure(OutputDir);
    end

    AllocateDataAndPlot(Data, ROIs, '[Contra-Ipsi]_A', {2, -1});
    PrintFigure(OutputDir);
    AllocateDataAndPlot(Data, ROIs, '[Contra-Ipsi]_V', {4, -3});
    PrintFigure(OutputDir);
    AllocateDataAndPlot(Data, ROIs, '[Contra-Ipsi]_T', {6, -5});
    PrintFigure(OutputDir);

    % Does not work because of subject 6
    %     AllocateDataAndPlot(Data, ROIs, '[A-T]_ipsi', {1, -5});
    %     AllocateDataAndPlot(Data, ROIs, '[A-T]_contra', {2, -6});

    AllocateDataAndPlot(Data, ROIs, '[V-T]_{ipsi}', {3, -5});
    PrintFigure(OutputDir);
    AllocateDataAndPlot(Data, ROIs, '[V-T]_{contra}', {4, -6});
    PrintFigure(OutputDir);

    ROIs = {'PT'};
    AllocateDataAndPlot(Data, ROIs, 'PT - [Contra-Ipsi]_T', {6, -5});
    PrintFigure(OutputDir);
    ROIs = {'V2'};
    AllocateDataAndPlot(Data, ROIs, 'V2 - [Contra-Ipsi]_T', {6, -5});
    PrintFigure(OutputDir);

    %%
    ROIs = { ...
            'PT'
            'V2'
           };

    for iROI = 1:size(ROIs, 1)

        Title = [ROIs{iROI} ' - [Contra & Ipsi]_T'];
        XLabel = {'T contra', 'T ipsi'};

        Cdt1 = 6;
        Cdt2 = 5;

        idx = ReturnRoiIndex(Data, ROIs{iROI});

        ToPlot = struct('Data', [], 'SubjectVec', [], 'ConditionVec', [], 'RoiVec', []);

        RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt1});
        RowsToSelect2 = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt2});

        ToPlot.Data = [ToPlot.Data; ...
                       Data(idx, 1).Data(RowsToSelect, :); ...
                       Data(idx, 1).Data(RowsToSelect2, :)];
        ToPlot.SubjectVec = [ToPlot.SubjectVec; ...
                             Data(idx, 1).SubjVec(RowsToSelect, :); ...
                             Data(idx, 1).SubjVec(RowsToSelect2, :)];
        ToPlot.ConditionVec = [ToPlot.ConditionVec; ...
                               Data(idx, 1).ConditionVec(RowsToSelect, :); ...
                               Data(idx, 1).ConditionVec(RowsToSelect2, :)];

        ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum([RowsToSelect; RowsToSelect2]), 1) * iROI];

        Opt.Specific{1} = ToPlot;
        Opt.Specific{1}.Titles = Title;
        Opt.Specific{1}.RoiNames = XLabel;

        Opt = SetPlottingOptions(Opt);

        PlotProfileAndBetas(Opt);

        PrintFigure(OutputDir);

    end

end

function  [NbLayers, AverageType] = GetOptions()

    NbLayers = 6;
    AverageType = 'median';

end

function Opt = SetPlottingOptions(Opt)

    [NbLayers] = GetOptions();

    Opt.PlotQuadratic = false;

    Opt.ErrorBarType = 'SEM';

    Opt.Alpha = 0.05 / 4;
    Opt.PlotPValue = true;
    Opt.PermutationTest.Do = true;
    Opt.PermutationTest.Plot = false;

    Opt.PlotSubjects = false;
    Opt.ShadedErrorBar = false;

    Opt.NbLayers = NbLayers;

    for i = 1:size(Opt.Specific, 2)
        Opt.Specific{1, i}.PlotMinMaxType = 'groupallcolumns'; % all group groupallcolumns
        Opt.Specific{1, i}.IsMvpa = false;
        Opt.Specific{1, i}.Ttest.SideOfTtest = 'both';
    end

end

function AllocateDataAndPlot(Data, ROIs, Titles, Cdt)

    ToPlot = struct('Data', [], 'SubjectVec', [], 'ConditionVec', [], 'RoiVec', []);

    for iROI = 1:size(ROIs, 1)

        idx = ReturnRoiIndex(Data, ROIs{iROI});

        switch numel(Cdt)

            case 1

                RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt{1}});

                ToPlot.Data = [ToPlot.Data; Data(idx, 1).Data(RowsToSelect, :)];
                ToPlot.SubjectVec = [ToPlot.SubjectVec; Data(idx, 1).SubjVec(RowsToSelect, :)];
                ToPlot.ConditionVec = [ToPlot.ConditionVec; Data(idx, 1).ConditionVec(RowsToSelect, :)];

                ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum(RowsToSelect), 1) * iROI];

            case 2

                RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt{1}});
                RowsToSelect2 = ReturnRowsToSelect({Data(idx, 1).ConditionVec, abs(Cdt{2})});

                tmp = Data(idx, 1).Data(RowsToSelect, :) + ...
                    sign(Cdt{2}) * Data(idx, 1).Data(RowsToSelect2, :);

                ToPlot.Data = [ToPlot.Data; tmp];
                ToPlot.SubjectVec = [ToPlot.SubjectVec; Data(idx, 1).SubjVec(RowsToSelect, :)];
                ToPlot.ConditionVec = [ToPlot.ConditionVec; Data(idx, 1).ConditionVec(RowsToSelect, :)];

                ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum(RowsToSelect), 1) * iROI];

        end

    end

    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = Titles;
    Opt.Specific{1}.RoiNames = ROIs;

    Opt = SetPlottingOptions(Opt);

    PlotProfileAndBetas(Opt);

end

function Data = LoadData(ROIs, InputDir)

    [NbLayers, AverageType] = GetOptions();

    for iROI =  1:numel(ROIs)

        Filename = ['Group-roi-', ROIs{iROI}, ...
                    '_average-', AverageType, ...
                    '_nbLayers-', num2str(NbLayers), '.mat' ...
                   ];

        load(fullfile(InputDir, Filename));

        Data(iROI, 1).RoiName = ROIs{iROI}; %#ok<*AGROW>
        Data(iROI, 1).Data = GrpData;
        Data(iROI, 1).ConditionVec = GrpConditionVec;
        Data(iROI, 1).SubjVec = SubjVec;

    end
end

function idx = ReturnRoiIndex(Data, RoiName)
    idx = find(strcmp({Data.RoiName}, RoiName));
end

function PrintFigure(OutputDir)
    Filename = strrep(get(gcf, 'name'), ' ', '_');
    print(gcf, fullfile(OutputDir, [Filename '.tif']), '-dtiff');
end
