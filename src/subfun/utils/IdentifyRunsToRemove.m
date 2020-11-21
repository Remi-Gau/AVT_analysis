function RunsToRemove = IdentifyRunsToRemove(RunVec, ConditionVec)
    %
    % Check that we have the same number of rows (conditions) in each run
    % It returns the runs that do not have all conditions
    %

    RunsToRemove = [];

    A = tabulate(RunVec);

    if numel(unique(A(:, 2))) > 1

        warning('We have different numbers of conditions in one run compare to the others.');

        RunsToRemove = find(A(:, 2) < numel(unique(ConditionVec)));

    end

end
