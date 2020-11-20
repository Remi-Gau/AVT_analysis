function [TestSide, P, STATS] = run_t_perm_test(ToPrint, iCdt, iROI, S_param, Data)

    if isfield(ToPrint, 'OneSideTTest')
        if isempty(ToPrint.OneSideTTest)
            Side = 2;
        else
            Side = ToPrint.OneSideTTest(iCdt, iROI, S_param);
        end
    else
        Side = 2;
    end

    switch Side
        case 1
            TestSide = 'left';
        case 2
            TestSide = 'both';
        case 3
            TestSide = 'right';
    end

    if ~isempty(ToPrint.ToPermute)

        STATS = [];

        % get the permutations
        for iPerm = 1:size(ToPrint.ToPermute, 1)
            tmp2 = ToPrint.ToPermute(iPerm, :);
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
        [~, P, ~, STATS] = ttest(Data, 0, 'alpha', 0.05, 'tail', TestSide);
    end
end
