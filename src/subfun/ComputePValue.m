% (C) Copyright 2020 Remi Gau
function [P, STATS, TestSide] = ComputePValue(Data, Opt)

    TestSide = 'both';

    if isfield(Opt, 'SideOfTtest') && ~isempty(Opt.SideOfTtest)
        TestSide = Opt.SideOfTtest;
    end

    if Opt.PermutationTest.Do

        STATS = [];

        % get the permutations
        for iPerm = 1:size(Opt.PermutationTest.Permutations, 1)
            tmp2 = Opt.PermutationTest.Permutations(iPerm, :);
            tmp2 = repmat(tmp2', 1, size(Data, 2));
            Perms(iPerm, :) = mean(Data .* tmp2);  %#ok<*AGROW>
        end

        % do the permutation test
        switch TestSide
            case 'left'
                P = sum(Perms < mean(Data)) / size(Perms, 1);
            case 'right'
                P = sum(Perms > mean(Data)) / size(Perms, 1);
            case 'both'
                P = sum( ...
                        abs(Perms) > ...
                        repmat(abs(mean(Data)), size(Perms, 1), 1)) ...
                    / size(Perms, 1);
        end

    else
        % or ttest
        [~, P, ~, STATS] = ttest(Data, 0, 'alpha', Opt.Alpha, 'tail', TestSide);

    end
end
