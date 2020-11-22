% (C) Copyright 2020 Remi Gau

function test_suite = test_define_train_and_test_runs %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_define_train_and_test_runsBasic()

    %% set up

    NbRuns = 20;
    TestRunsList{1} = (1:NbRuns)';
    RunSubSamp = 1;
    cv = 1:NbRuns;
    iCV = 1;

    %% use function to test

    [TestRuns, TrainRuns] = define_train_and_test_runs(NbRuns, TestRunsList, RunSubSamp, cv, iCV);

    %% assert that output content / type / size is what you expect

    assertEqual(TestRuns, [true false(1, NbRuns - 1)]);
    assertEqual(TrainRuns, [false true(1, NbRuns - 1)]);

end
