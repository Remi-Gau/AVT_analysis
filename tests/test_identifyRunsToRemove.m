% (C) Copyright 2020 Remi Gau

function test_suite = test_identifyRunsToRemove %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_identifyRunsToRemoveBasic()

    RunVec = [1 1 2 2];

    RunsToRemove = identifyRunsToRemove(RunVec);

    assertEqual(RunsToRemove, []);

    RunVec = [1 1 1 2 2];
    ConditionVec = [1 2 3 1 2];

    RunsToRemove = identifyRunsToRemove(RunVec, ConditionVec);

    assertEqual(RunsToRemove, 2);

    RunVec = [1 1 1 2 2 3 3];
    ConditionVec = [1 2 3 1 2 2 3];

    RunsToRemove = identifyRunsToRemove(RunVec, ConditionVec);

    assertEqual(RunsToRemove, [2; 3]);

end
