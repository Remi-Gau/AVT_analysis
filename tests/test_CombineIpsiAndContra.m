% (C) Copyright 2020 Remi Gau

function test_suite = test_CombineIpsiAndContra %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_CombineIpsiAndContraBasic()

    Data = repmat([zeros(1, 3); ...
                   ones(1, 3)], ...
                  4, 1);
    ConditionVec = ([1 2 3 4 1 2 3 4])';
    RunVec = ([1 1 1 1 2 2 2 2])';

    [Data, ConditionVec, RunVec] = CombineIpsiAndContra(Data, ConditionVec, RunVec, 'pool');

    assertEqual(RunVec, ([1 1 2 2])');
    assertEqual(ConditionVec, ([1 3 1 3])');
    assertEqual(Data, repmat([zeros(1, 3), ones(1, 3)], ...
                             4, 1));

end

function test_CombineIpsiAndContraMean()

    Data = repmat([zeros(1, 3); ...
                   ones(1, 3)], ...
                  4, 1);
    ConditionVec = ([1 2 3 4 1 2 3 4])';
    RunVec = ([1 1 1 1 2 2 2 2])';

    [Data, ConditionVec, RunVec] = CombineIpsiAndContra(Data, ConditionVec, RunVec, 'mean');

    assertEqual(RunVec, ([1 1 2 2])');
    assertEqual(ConditionVec, ([1 3 1 3])');
    assertEqual(Data, repmat([0.5 0.5 0.5], ...
                             4, 1));

end
