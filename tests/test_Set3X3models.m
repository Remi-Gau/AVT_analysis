% (C) Copyright 2020 Remi Gau

function test_suite = test_Set3X3models %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_Set3X3modelsBasic

    M = Set3X3models();

end
