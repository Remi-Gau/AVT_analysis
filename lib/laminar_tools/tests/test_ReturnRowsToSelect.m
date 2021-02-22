% (C) Copyright 2020 Remi Gau

function test_suite = test_ReturnRowsToSelect %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ReturnRowsToSelectBasic()

    SubjectVec = [1 1 2 2];

    RowsToSelect = ReturnRowsToSelect({SubjectVec, 1});

    assertEqual(RowsToSelect, [true(2, 1); false(2, 1)]);

end
