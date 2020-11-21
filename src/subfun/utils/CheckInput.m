function [RoiData, RunVec, ConditionVec] = CheckInput(RoiData, RunVec, ConditionVec, IsTarget)

    % Remove target data
    % In many cases this might no be necessary but it could make the data matrix
    % lighter and thus easier to pass around.
    if ~IsTarget
        ConditionVec(ConditionVec > 6) = 0;
    end
    RoiData(ConditionVec == 0, :) = [];
    RunVec(ConditionVec == 0) = [];
    ConditionVec(ConditionVec == 0) = [];

    % make sure all runs have the same number of condtions
    RunsToRemove = IdentifyRunsToRemove(RunVec, ConditionVec);
    if ~isempty(RunsToRemove)
        RoiData(RunVec == RunsToRemove, :) = [];
        ConditionVec(RunVec == RunsToRemove) = [];
        RunVec(RunVec == RunsToRemove) = [];
    end

    CheckSizeOutput(RoiData, ConditionVec, RunVec);

end
