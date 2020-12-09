function P = RunSignPermutationTest(Data, Permutations, TestSide)
        %
    % Computes p value of a one sample t-test using an exact sign permutation test.
    %
    % USAGE::
    %
    %   P = RunSignPermutationTest(Data, Permutations, TestSide)
    %
    % :param Data: (m X n) with m = number of subjects and n = number of
    %              variables measured
    % :type Data: array
    % :param Permutations: Indicates the sign that must taken by each each value on each permutation.
    %                      Dimensions are (m X n) with m = number of permutation
    %                      and n = number of subjects.
    % :type Permutations: array
    % :param TestSide: determines if we are running a one sided (``left``, ``right``)
    %                  or 2-sided test (``both``).
    % :type TestSide: string    
    %
    % :returns:
    %           :P: (array) p value for each variable
    
    if ~(size(Data, 1) == size(Permutations, 2))
        error('number of data points must match that in the sign permutation matrix.')
    end
    
    NbPermutations = size(Permutations, 1);
    
            % do the sign permutations
        for iPerm = 1:NbPermutations
            tmp2 = Permutations(iPerm, :);
            tmp2 = repmat(tmp2', 1, size(Data, 2));
            Perms(iPerm, :) = mean(Data .* tmp2);  %#ok<*AGROW>
        end

        % do the permutation test
        switch lower(TestSide)
            case 'left'
                        % check the proportion of permutation results that are inferior to
        % the mean of my sample
                P = sum(Perms < mean(Data)) / NbPermutations;
            case 'right'
                % same but the other way
                P = sum(Perms > mean(Data)) / NbPermutations;
            case 'both'
                % Again the same but 2 sided
                P = sum( ...
                        abs(Perms) > ...
                        repmat(abs(mean(Data)), NbPermutations, 1)) / NbPermutations;
            otherwise
                error('unknown test side: must be left, right or both')
        end
    
end