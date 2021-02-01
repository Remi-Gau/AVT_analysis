% (C) Copyright 2020 Remi Gau

function test_suite = test_RunSignPermutationTest %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_RunSignPermutationTestBasic

    TestTolerance = 5 * 1e-3;

    NbVariables = 10000;
    NbSubjects = 10;

    Data = randn(10, NbVariables);

    Opt.PermutationTest.Do = true;
    Opt.PermutationTest = CreatePermutationList(Opt.PermutationTest);

    Ttest.PermutationTest.Plot = true();

    % run tests and make sure that we have tolerable false positive rate
    Ttest.SideOfTtest =  'both';
    P = RunSignPermutationTest(Data, Opt, Ttest);
    CheckFalsePositiveRate(P, TestTolerance);

    Ttest.SideOfTtest =  'right';
    P = RunSignPermutationTest(Data, Opt, Ttest);
    CheckFalsePositiveRate(P, TestTolerance);

    Ttest.SideOfTtest =  'left';
    P = RunSignPermutationTest(Data, Opt, Ttest);
    CheckFalsePositiveRate(P, TestTolerance);

end

% function test_ComputePValuePermutationShift
%
%     TestTolerance = 5*1e-3;
%     NbVariables = 10000;
%
%     ValueToTest = 10;
%
%     NbSubjects = 10;
%
%     Opt.Ttest.PermutationTest.Do = true();
%     Opt.Ttest.ValueToTest = ValueToTest;
%
%     % create dummy data
%     Data = randn(10, NbVariables) + ValueToTest;
%
%     Opt = CreatePermutationList(Opt);
%
%     % run tests and make sure that we have tolerable false positive rate
%     Opt.Ttest.SideOfTtest =  'both';
%     P = RunSignPermutationTest(Data, Opt);
%     CheckFalsePositiveRate(P, TestTolerance);
%
% end

function CheckFalsePositiveRate(P, TestTolerance)
    assertElementsAlmostEqual( ...
                              sum(P < 0.05) / numel(P), ...
                              0.05, ...
                              'absolute', TestTolerance);
end
