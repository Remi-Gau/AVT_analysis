% (C) Copyright 2020 Remi Gau

function [P, STATS] = ComputePValue(Data, Opt)
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

    if ~isfield(Opt.Ttest, 'ValueToTest') || isempty(Opt.Ttest.ValueToTest)
        Opt.Ttest.ValueToTest = 0;
    end

    if ~isfield(Opt.Ttest, 'SideOfTtest') && isempty(Opt.Ttest.SideOfTtest)
        Opt.Ttest.SideOfTtest = 'both';
    end

    % sing permutation test
    if Opt.Ttest.PermutationTest.Do

        STATS = [];

        P = RunSignPermutationTest(Data, Opt);

    else

        % or ttest
        [~, P, ~, STATS] = ttest( ...
                                 Data, ...
                                 Opt.Ttest.ValueToTest, ...
                                 'alpha', Opt.Alpha, ...
                                 'tail', Opt.Ttest.SideOfTtest);

    end
end
