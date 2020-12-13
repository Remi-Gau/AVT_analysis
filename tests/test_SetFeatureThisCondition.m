% (C) Copyright 2020 Remi Gau

function test_suite = test_SetFeatureThisCondition %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_SetFeatureIpsiContraScaledBasic

    Models{1}.Ac = [1; zeros(5, 1)];

    RowToAdd = 2;
    col_num = [1 4];

    Models = SetFeatureThisCondition(Models, col_num, RowToAdd);

    Expected{1}.Ac(:, 1) = [1; zeros(5, 1)];
    Expected{1}.Ac(2, 4, 2) = 1;

    assertEqual(Models, Expected);

end
