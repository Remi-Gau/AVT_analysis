% (C) Copyright 2020 Remi Gau

function test_suite = test_ComputePValue %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ComputePValuePermutation

    TestTolerance = 5 * 1e-3;
    NbVariables = 10000;

    % will only work with 10 subjects for now
    NbSubjects = 10;

    Opt.Ttest.PermutationTest.Do = true();

    % create dummy data
    Data = randn(10, NbVariables);

    Opt = CreatePermutationList(Opt);

    % run tests and make sure that we have tolerable false positive rate
    Opt.Ttest.SideOfTtest =  'both';
    P = ComputePValue(Data, Opt);
    CheckFalsePositiveRate(P, TestTolerance);

    Opt.Ttest.SideOfTtest =  'right';
    P = ComputePValue(Data, Opt);
    CheckFalsePositiveRate(P, TestTolerance);

    Opt.Ttest.SideOfTtest =  'left';
    P = ComputePValue(Data, Opt);
    CheckFalsePositiveRate(P, TestTolerance);

end

function CheckFalsePositiveRate(P, TestTolerance)
    assertElementsAlmostEqual( ...
                              sum(P < 0.05) / numel(P), ...
                              0.05, ...
                              'absolute', TestTolerance);
end
