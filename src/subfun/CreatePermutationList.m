% (C) Copyright 2020 Remi Gau
function  Opt = CreatePermutationList(Opt)

    Permutations = [];
    if Opt.PermutationTest.Do

        sets = {};
        for iSub = 1:10
            sets{iSub} = [-1 1]; %#ok<*AGROW>
        end

        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        Permutations = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

    end

    Opt.PermutationTest.Permutations = Permutations;

end
