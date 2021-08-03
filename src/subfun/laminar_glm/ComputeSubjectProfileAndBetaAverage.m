% (C) Copyright 2020 Remi Gau

function Opt = ComputeSubjectProfileAndBetaAverage(Opt, iColumn)

    DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, Opt.PlotQuadratic);

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
