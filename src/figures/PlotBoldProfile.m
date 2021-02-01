function PlotBoldProfile

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

    Cdt = 1;

    ToPlot.Data = [];
    ToPlot.SubjectVec = [];
    ToPlot.ConditionVec = [];
    ToPlot.RoiVec = [];

    for iROI = 1:size(Data, 1)

        RowsToSelect = ReturnRowsToSelect({Data(iROI, 1).ConditionVec, Cdt});

        ToPlot.Data = [ToPlot.Data; Data(iROI, 1).Data(RowsToSelect, :)];
        ToPlot.SubjectVec = [ToPlot.SubjectVec; Data(iROI, 1).SubjVec(RowsToSelect, :)];
        ToPlot.ConditionVec = [ToPlot.ConditionVec; Data(iROI, 1).ConditionVec(RowsToSelect, :)];

        ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum(RowsToSelect), 1) * iROI];

    end

    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = 'A ipsi';
    Opt.Specific{1}.RoiNames = ROIs;

    Opt = SetPlottingOptions(Opt);

    PlotProfileAndBetas(Opt);

end

function  [NbLayers, AverageType] = GetOptions()

    NbLayers = 6;
    AverageType = 'median';

end

function Opt = SetPlottingOptions(Opt)

    [NbLayers] = GetOptions();

    Opt.PlotQuadratic = false;

    Opt.ErrorBarType = 'SEM';

    Opt.Alpha = 0.05;
    Opt.PlotPValue = true;
    Opt.PermutationTest.Do = false;
    Opt.PermutationTest.Plot = false;

    Opt.PlotSubjects = false;
    Opt.ShadedErrorBar = true;

    Opt.NbLayers = NbLayers;

    for i = 1:size(Opt.Specific, 2)
        Opt.Specific{1, i}.PlotMinMaxType = 'group'; % all group groupallcolumns
        Opt.Specific{1, i}.IsMvpa = false;
        Opt.Specific{1, i}.Ttest.SideOfTtest = 'both';
    end

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
