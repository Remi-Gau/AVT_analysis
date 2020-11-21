% (C) Copyright 2020 Remi Gau

function test_suite = test_templateTest %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_templateTestBasic()

    %% set up

    % cfg.input_1 = ...

    %% use function to test

    % actualOupout = foo(cfg);

    %% assert that output content / type / size is what you expect

    % expectedOuput = X;

    % assertEqual(actualOupout, expectedOuput)

    %% clean up (delete temporary files that were created)

end
