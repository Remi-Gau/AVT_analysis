% (C) Copyright 2020 Remi Gau

function test_suite = test_AllScaled %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_Set6X6modelsBasic

    M{1}.Ac = [0 0 0 0 0 0]';

    IpsiContraScaled = 1;

    M = AllScaled(M, IpsiContraScaled);

end
