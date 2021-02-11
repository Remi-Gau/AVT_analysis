% (C) Copyright 2020 Remi Gau

function PlotProfileAndBetas(Opt)

    Opt = CheckProfilePlottingOptions(Opt);

    figure('Name', Opt.Title, ...
           'Position', Opt.FigDim);

    SetFigureDefaults(Opt);

    for iColumn = 1:size(Opt.Specific, 2)

        Opt = ComputeSubjectProfileAndBetaAverage(Opt, iColumn);

        AllData(1, iColumn) = Opt.Specific{1, iColumn}.Group;
        BetaData(1, iColumn) = Opt.Specific{1, iColumn}.Group.Beta;

    end

    for iColumn = 1:size(Opt.Specific, 2)

        %% Plot profiles
        [Min, Max] = ComputeMinMax(Opt.Specific{1, iColumn}.PlotMinMaxType, ...
                                   AllData, ...
                                   Opt, ...
                                   iColumn);
        Opt.Specific{1, iColumn}.Group.Min = Min;
        Opt.Specific{1, iColumn}.Group.Max = Max;

        PlotGroupProfile(Opt, iColumn);

        %% Plot s parameters
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

    mtit(upper(Opt.Title), ...
         'fontsize', Opt.Fontsize + 4, ...
         'xoff', 0, ...
         'yoff', .05);

end

function Opt = ComputeSubjectProfileAndBetaAverage(Opt, iColumn)

    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, true);

    RoiVec = Opt.Specific{1, iColumn}.RoiVec;
    ConditionVec = Opt.Specific{1, iColumn}.ConditionVec;

    RoiList = unique(RoiVec);
    CdtList = unique(ConditionVec);

    Group = struct('Data', [], 'Mean', [], 'UpperError', [], 'LowerError', []);
    GroupBeta = Group;

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

            if Opt.PerformDeconvolution
                Data = PerfomDeconvolution(Data, Opt.NbLayers);
            end

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

end

function Structure = AppendMeanAndError(Data, Structure, Opt)

    Structure.Data = [Structure.Data; Data];
    Structure.Mean(end + 1, :) = mean(Data);
    [Lower, Upper] = ComputeDispersionIndex(Data, Opt);
    Structure.UpperError(end + 1, :) = Upper;
    Structure.LowerError(end + 1, :) = Lower;

end
