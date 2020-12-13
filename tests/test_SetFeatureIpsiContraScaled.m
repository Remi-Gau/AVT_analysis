% (C) Copyright 2020 Remi Gau

function test_suite = test_SetFeatureIpsiContraScaled %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_SetFeatureIpsiContraScaledBasic

    Do = 1;

    Models{1}.Ac = [1; zeros(5, 1)];

    RowToAdd = 2;
    col_num = [1 3];
    Value2Check = 1;
    IpsiContraScaled = 1;

    Models = SetFeatureIpsiContraScaled(Models, IpsiContraScaled, col_num, Value2Check, RowToAdd);

    Expected{1}.Ac(:, 1) = [1; zeros(5, 1)];

    assertEqual(Models, Expected);

    %%
    IpsiContraScaled = 2;
    Value2Check = 2;
    Models = SetFeatureIpsiContraScaled(Models, IpsiContraScaled, col_num, Value2Check, RowToAdd);

    Expected{1}.Ac(:, 1) = [1; zeros(5, 1)];
    Expected{1}.Ac(2, 3 - 1, 2) =  1;

    assertEqual(Models, Expected);

end
