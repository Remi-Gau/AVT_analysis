% (C) Copyright 2020 Remi Gau

function P = RunSignPermutationTest(Data, Opt, Ttest)
    %
    % Computes p value of a one sample t-test using an exact sign permutation test.
    %
    % USAGE::
    %
    %   P = RunSignPermutationTest(Data, Opt)
    %
    % :param Data: (m X n) with m = number of subjects and n = number of
    %              variables measured
    % :type Data: array
    % :type Opt: structure
    % :param Opt:
    %
    %
    %   - ``Opt.Ttest.PermutationTest.Permutations`` Indicates the sign that must taken
    %     by each each value on each permutation.
    %     Dimensions are (m X n) with m = number of permutation and n = number of subjects.
    %
    %   - ``Opt.Ttest.SideOfTtest`` determines if we are running a one sided (``left``, ``right``)
    %     or 2-sided test (``both``).
    %
    %   - ``Opt.Ttest.PermutationTest.Plot```if set to ``true`` and
    %   ``size(Data,2) == 1`` this will plot the null distribution and the
    %   mean of the data.
    %
    %   NOT IMPLEMENTED YET
    %   - ``Opt.Ttest.ValueToTest`` if you want to shift the n,ull distribution
    %     in case you don't want to test against ``mean == 0``.
    %
    % :returns:
    %           :P: (array) p value for each variable
    %
    % EXAMPLE::
    %
    %     NbVariables = 1;
    %     NbSubjects = 10;
    %
    %     Data = randn(10, NbVariables);
    %
    %     Opt.Ttest.PermutationTest.Do = true;
    %     Opt = CreatePermutationList(Opt);
    %
    %     Opt.Ttest.SideOfTtest = 'both';
    %     Opt.Ttest.PermutationTest.Plot = true();
    %     P = RunSignPermutationTest(Data, Opt);
    %

    if ~isfield(Ttest, 'ValueToTest') || isempty(Ttest.ValueToTest)
        Ttest.ValueToTest = 0;
    elseif Ttest.ValueToTest == 0
    else
        error('test against other values than 0 not yet implemented.');
    end

    if ~isfield(Ttest, 'SideOfTtest') && isempty(Ttest.SideOfTtest)
        Ttest.SideOfTtest = 'both';
    end

    Permutations = Opt.PermutationTest.Permutations;
    ValueToTest = Ttest.ValueToTest;
    SideOfTtest = Ttest.SideOfTtest;

    if ~(size(Data, 1) == size(Permutations, 2))
        error('number of data points must match that in the sign permutation matrix.');
    end

    NbPermutations = size(Permutations, 1);

    % do the sign permutations
    for iPerm = 1:NbPermutations
        tmp2 = Permutations(iPerm, :);
        tmp2 = repmat(tmp2', 1, size(Data, 2));
        NullDistribution(iPerm, :) = mean(Data .* tmp2);  %#ok<*AGROW>
    end

    % shift null distribution
    NullDistribution = NullDistribution + ValueToTest;

    % do the permutation test
    switch lower(SideOfTtest)
        case 'left'
            % check the proportion of permutation results that are inferior to
            % the mean of my sample
            P = sum(NullDistribution < mean(Data)) / NbPermutations;
        case 'right'
            % same but the other way
            P = sum(NullDistribution > mean(Data)) / NbPermutations;
        case 'both'
            % Again the same but 2 sided
            P = sum( ...
                    abs(NullDistribution) > ...
                    repmat(abs(mean(Data)), NbPermutations, 1)) / NbPermutations;
        otherwise
            error('unknown test side: must be left, right or both');
    end

    if size(Data, 2) == 1 && Opt.PermutationTest.Plot
        figure();
        hold on;
        hist(NullDistribution, 20);
        MAX = max(hist(NullDistribution, 20));
        plot([mean(Data) mean(Data)], [0 MAX], '-r');
    end

end
