function cv_mat = permutate_labels(opt, cv_mat, svm)
    % Permute class within sessions when all sessions are included,
    % so not when running a leaning curve.
    %
    % Requires ``opt.permutation.test`` to be set to ``true``.
    %
    %
    % (C) Copyright 2020 Remi Gau

    if opt.permutation.test && iPerm > 1

        for iRun = 1:max(cv_mat(:, 2))

            cdt_2_perm = all([ ...
                              ismember(cv_mat(:, 1), svm.class), ...
                              ismember(cv_mat(:, 2), iRun)], ...
                             2);

            temp = cv_mat(cdt_2_perm, 1);

            cv_mat(cdt_2_perm, 1) = temp(randperm(length(temp)));

        end

    end

end
