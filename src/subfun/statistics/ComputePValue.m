% (C) Copyright 2020 Remi Gau
function [P, STATS, TestSide] = ComputePValue(Data, Opt)
    %
    % Computes p value of a one sample t-test using either a regular parametric t-test 
    % or an exact sign permutation test.
    %
    % USAGE::
    %
    %   [P, STATS, TestSide] = ComputePValue(Data, Opt)
    %
    % :param Data: (m X n) with m = number of subjects and n = number of
    %              variables measured
    % :type Data: array
    % :param Opt: ``Opt.PermutationTest.Do`` must be set to true to run the
    %             sign permutation test. ``Opt.SideOfTtest`` determines if we
    %             are running a one sided (``left``, ``right``) or 2-sided test
    %             (``both``)
    % :type Opt: structure
    %
    % :returns:
    %           :P: (array) (dimension)
    %           :STATS: (structure) contains extra info like confidence interval
    %                   (only for parametric t-test)
    %           :TestSide: (string)
    %
    
    TestSide = 'both';

    if isfield(Opt, 'SideOfTtest') && ~isempty(Opt.SideOfTtest)
        TestSide = Opt.SideOfTtest;
    end

    % sing permutation test
    if Opt.PermutationTest.Do

        STATS = [];

        P = RunSignPermutationTest(Data, Opt.PermutationTest.Permutations, TestSide);

    else
        % or ttest
        [~, P, ~, STATS] = ttest(Data, 0, 'alpha', Opt.Alpha, 'tail', TestSide);

    end
end
