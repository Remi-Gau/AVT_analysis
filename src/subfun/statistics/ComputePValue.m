% (C) Copyright 2020 Remi Gau

function [P, STATS] = ComputePValue(Data, Opt, Ttest)
    %
    % Computes p value of a one sample t-test using either a regular parametric t-test
    % or an exact sign permutation test.
    %
    % USAGE::
    %
    %   [P, STATS, TestSide] = ComputePValue(Data, Opt, ValueToTest == 0)
    %
    % :param Data: (m X n) with m = number of subjects and n = number of
    %              variables measured
    % :type Data: array
    % :param Opt: ``Opt.PermutationTest.Do`` must be set to true to run the
    %             sign permutation test. ``Opt.SideOfTtest`` determines if we
    %             are running a one sided (``left``, ``right``) or 2-sided test
    %             (``both``)
    % :type Opt: structure
    % :param ValueToTest: mean of the null distribution to test against
    % :type ValueToTest: scalar
    %
    % :returns:
    %           :P: (array) (dimension)
    %           :STATS: (structure) contains extra info like confidence interval
    %                   (only for parametric t-test)
    %           :TestSide: (string)
    %

    if ~isfield(Ttest, 'ValueToTest') || isempty(Ttest.ValueToTest)
        Ttest.ValueToTest = 0;
    end

    if ~isfield(Ttest, 'SideOfTtest') && isempty(Ttest.SideOfTtest)
        Ttest.SideOfTtest = 'both';
    end

    % sing permutation test
    if Opt.PermutationTest.Do

        STATS = [];

        P = RunSignPermutationTest(Data, Opt, Ttest);

    else

        % or ttest
        [~, P, ~, STATS] = ttest( ...
                                 Data, ...
                                 Ttest.ValueToTest, ...
                                 'alpha', Opt.Alpha, ...
                                 'tail', Ttest.SideOfTtest);

    end
end
