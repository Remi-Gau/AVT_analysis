% (C) Copyright 2020 Remi Gau

function  PermutationTest = CreatePermutationList(PermutationTest)
    %
    % Creates a "list" of sign changes to implement to run an exact sign-permutation
    % test. Currently only works for a maximum of 10 data points (otherwise the
    % number of possible permutations gets too high - and I only deal in small samples).
    %
    % USAGE::
    %
    %   Opt = CreatePermutationList(Opt)
    %
    % :param Opt: Will only run if ``Opt.Ttest.PermutationTest.do`` is ``true``
    % :type Opt: structure
    %
    % :returns:
    %           :Opt: (structure) with extrafield
    %                 ``Opt.Ttest.PermutationTest.Permutations`` containing the array
    %                 of sign changes to apply.
    %
    %

    Permutations = [];
    if PermutationTest.Do

        sets = {};
        for iSub = 1:10
            sets{iSub} = [-1 1]; %#ok<*AGROW>
        end

        % Gets all the possible permutations possible (via cartesian product):
        % might no be necessary if you have "a lot" of subjects
        % then you can just randomly permutate X number of times
        % but with 10 subjects that's only 1024 permutations
        % and that gives you an exact permutation test
        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        Permutations = [a(:), b(:), c(:), d(:), e(:), ...
                        f(:), g(:), h(:), i(:), j(:)];

    end

    PermutationTest.Permutations = Permutations;

end
