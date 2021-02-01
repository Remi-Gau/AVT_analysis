% (C) Copyright 2020 Remi Gau

function PlotProfileAndBetas(Opt)

    Opt = CheckPlottingOptions(Opt);

    figure('Name', 'test', ...
           'Position', Opt.FigDim);

    SetFigureDefaults(Opt);

    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, true);

    %% Compute subject average for profile and beta
    for iColumn = 1:Opt.m

        RoiVec = Opt.Specific{1, iColumn}.RoiVec;
        ConditionVec = Opt.Specific{1, iColumn}.ConditionVec;

        RoiList = unique(RoiVec);
        CdtList = unique(ConditionVec);

        Group.Data = [];
        Group.Mean = [];
        Group.UpperError = [];
        Group.LowerError = [];

        GroupBeta.Data = [];
        GroupBeta.Mean = [];
        GroupBeta.UpperError = [];
        GroupBeta.LowerError = [];

        GroupRoiVec = [];
        GroupConditionVec = [];
        GroupSubjectVec = [];

        for iRoi = 1:numel(RoiList)

            for iCdt = 1:numel(CdtList)

                Criteria = {
                            RoiVec, RoiList(iRoi); ...
                            ConditionVec, CdtList(iCdt)};
                RowsToSelect = ReturnRowsToSelect(Criteria);

                Data = Opt.Specific{1, iColumn}.Data(RowsToSelect, :);
                SubjectVec = Opt.Specific{1, iColumn}.SubjectVec(RowsToSelect, :);

                % compute S parameter betas
                BetaHat = RunLaminarGlm(Data, DesignMatrix);
                DataTmp = ComputeSubjectAverage(BetaHat, SubjectVec);
                GroupBeta = AppendMeanAndError(DataTmp, GroupBeta, Opt);

                % compute profile for each subject
                [DataTmp, SubjTmp] = ComputeSubjectAverage(Data, SubjectVec);
                Group = AppendMeanAndError(DataTmp, Group, Opt);

                GroupSubjectVec = [GroupSubjectVec; SubjTmp]; %#ok<*AGROW>
                GroupRoiVec = [GroupRoiVec; ones(size(SubjTmp)) * iRoi];
                GroupConditionVec = [GroupConditionVec; ones(size(SubjTmp)) * iCdt];

            end

        end

        Opt.Specific{1, iColumn}.Group = Group;
        Opt.Specific{1, iColumn}.Group.Beta = GroupBeta;
        Opt.Specific{1, iColumn}.Group.SubjectVec = GroupSubjectVec;
        Opt.Specific{1, iColumn}.Group.RoiVec = GroupRoiVec;
        Opt.Specific{1, iColumn}.Group.ConditionVec = GroupConditionVec;

        AllData(1, iColumn) = Opt.Specific{1, iColumn}.Group;
        BetaData(1, iColumn) = Opt.Specific{1, iColumn}.Group.Beta;

    end

    for iColumn = 1:Opt.m

        [Min, Max] = ComputeMinMax(Opt.Specific{1, iColumn}.PlotMinMaxType, ...
                                   AllData, ...
                                   Opt, ...
                                   iColumn);
        Opt.Specific{1, iColumn}.Group.Min = Min;
        Opt.Specific{1, iColumn}.Group.Max = Max;

        PlotGroupProfile(Opt, iColumn);

        SparamToPlot = 2;
        if Opt.PlotQuadratic
            SparamToPlot = 3;
        end

        for iSparam = 1:SparamToPlot

            [Min, Max] = ComputeMinMax(Opt.Specific{1, iColumn}.PlotMinMaxType, ...
                                       BetaData, ...
                                       Opt, ...
                                       iColumn, ...
                                       iSparam);
            Opt.Specific{1, iColumn}.Group.Beta.Min = Min;
            Opt.Specific{1, iColumn}.Group.Beta.Max = Max;

            PlotBetasLaminarGlm(Opt, iSparam, iColumn);

        end

    end

end

function Opt = CheckPlottingOptions(Opt)

    Opt.Fontsize = 8;
    Opt.Visible = 'on';

    % define subplot grid
    Opt.m = size(Opt.Specific, 2);

    Opt.n = 3;
    if Opt.PlotQuadratic
        Opt.n = 4;
    end
    Opt.n = Opt.n + 1;

    switch Opt.m
        case 1
            Opt.FigDim = [50, 50, 600, 800];
        case 2
            Opt.FigDim = [50, 50, 1200, 800];
        case 3
            Opt.FigDim = [50, 50, 1800, 800];
    end

    if Opt.PlotQuadratic
        Opt.FigDim(4) = 1000;
    end

    if ~isfield(Opt, 'PermutationTest')
        Opt.PermutationTest.Do = false;
    end

    if ~isfield(Opt, 'PlotPValue')
        Opt.PlotPValue = true;
    end

    if ~isfield(Opt, 'LineColors')
        Opt.LineColors = RoiColours();
    end

    if Opt.PermutationTest.Do
        Opt.PermutationTest = CreatePermutationList(Opt.PermutationTest);
    end

    if contains(Opt.ErrorBarType, 'CI')
        Opt.ShadedErrorBar = false;
    end

    for i = 1:Opt.m

        Opt.Specific{i}.NbLines = prod([ ...
                                        numel(unique(Opt.Specific{i}.ConditionVec)); ...
                                        numel(unique(Opt.Specific{i}.RoiVec))]);

        if Opt.Specific{i}.NbLines > 1
            Opt.ShadedErrorBar = false;
            Opt.PlotSubjects = false;
        end

    end

end

function Structure = AppendMeanAndError(Data, Structure, Opt)

    Structure.Data = [Structure.Data; Data];
    Structure.Mean(end + 1, :) = mean(Data);
    [Lower, Upper] = ComputeDispersionIndex(Data, Opt);
    Structure.UpperError(end + 1, :) = Upper;
    Structure.LowerError(end + 1, :) = Lower;

end
