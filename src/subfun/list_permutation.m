function  [permutation, suffix] = list_permutation(WithPerm, NbSub)

    if WithPerm

        suffix = '_perm';

        sets = {};
        for iSub = 1:NbSub
            sets{iSub} = [-1 1]; %#ok<*AGROW>
        end
        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        permutation = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

    else
        suffix = '_ttest';

        permutation = [];

    end

end
