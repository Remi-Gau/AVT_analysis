% (C) Copyright 2020 Remi Gau

function test_suite = test_define_test_runs_list %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_define_test_runs_listBasic()

    %%

    iSub = 1;
    opt.runs.curve = false;
    opt.runs.loro = true;

    TestSessList = define_test_runs_list(opt, iSub);

    assertEqual(TestSessList, {(1:20)'})
    
    %%
    iSub = 1;
    opt.runs.curve = false;
    opt.runs.loro = true;
    listValidRuns = [1:8, 10, 12:19];

    TestSessList = define_test_runs_list(opt, iSub, listValidRuns);

    assertEqual(TestSessList, {([1:8, 10, 12:19])'})
    
    %%

    iSub = 1;
    opt.runs.curve = false;
    opt.runs.loro = false;
    opt.permutation.test = false;
    opt.runs.maxcv = 10;
    
    TestSessList = define_test_runs_list(opt, iSub);

    % TODO
    %  assertEqual(TestSessList, {(1:20)'})

end
