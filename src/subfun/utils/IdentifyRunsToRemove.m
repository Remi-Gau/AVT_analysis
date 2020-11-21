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

    A = tabulate(RunVec);

    if numel(unique(A(:, 2))) > 1

        warning('We have different numbers of conditions in one run compare to the others.');

        RunsToRemove = find(A(:, 2) < numel(unique(ConditionVec)));

    end

end
