% (C) Copyright 2020 Remi Gau

function test_suite = test_CheckSizeOutput %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_CheckSizeOutputBasic()

    RunVec = ([1 1 2 2 3 3])';
    RoiData = repmat([zeros(1, 3); ones(1, 3)], 3, 1);
    ConditionVec = ([1 2 1 2 1 2 1])';

    assertExceptionThrown(@()CheckSizeOutput(RoiData, ConditionVec, RunVec), ...
                          'CheckSizeOutput:NonMatchingSize');

end
