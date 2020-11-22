function [TestRuns, TrainRuns] = define_train_and_test_runs(NbRuns, TestRunsList, RunSubSamp, cv, iCV)

    TestRuns = [];  %#ok<*NASGU>
    TrainRuns = [];

    % Separate training and test sessions
    [TestRuns, TrainRuns] = deal(false(size(1:NbRuns)));

    TestRuns(TestRunsList{RunSubSamp, 1}(iCV, :)) = true;
    TrainRuns(setdiff(cv(RunSubSamp, :), TestRuns)) = true;

end
