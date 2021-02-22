% (C) Copyright 2020 Remi Gau

function RunsToRemove = IdentifyRunsToRemove(RunVec, ConditionVec)
    %
    % Check that the is the same number of rows (conditions) in each run.
    % It returns the runs that do not have all conditions.
    %
    % USAGE::
    %
    %   RunsToRemove = IdentifyRunsToRemove(RunVec, ConditionVec)
    %

    RunsToRemove = [];

    RunsList = unique(RunVec);

    Count = [];
    for i = 1:numel(RunsList)
        Count(end + 1) = sum(RunVec == RunsList(i));
    end

    if numel(unique(Count)) > 1

        warning('We have different numbers of conditions in one run compare to the others.');

        RunsToRemove = find(Count < numel(unique(ConditionVec)));

    end

end
