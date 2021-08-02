%% HELPER FUNCTIONS

function p_str = convert_pvalue(p)
    if p < 0.001
        p_str = 'p<0.001';
    else
        p_str = sprintf('p=%.3f', p);
    end
end

function p_ttest = compare_results(i, model)

    if size(model.X, 2) == 4
        ROIs = { ...
                'A1'; ...
                'PT'; ...
                'V1'; ...
                'V2-3'};
        ROI_nb = [1 1 2 2];
        side_idx = [1 2 1 2];
        s_param = {'Cst', 'Lin', 'Cst', 'Lin'};
    elseif size(model.X, 2) == 2
        ROIs = model.ROIs;
        ROI_nb = [1 2];
        side_idx = [1 1];
        s_param = model.s_param;
    end

    betas = model.Y(logical(model.X(:, i))); % get betas
    side = model.test_side{side_idx(i)}; % get side for the test

    [~, p_ttest, ~, STATS] = ttest(betas, 0, 'tail', side);

    % display the results of perm and t-test
    fprintf('%s %s\t t(%i) = %f \t p = %f \t (p_perm = %f)\n', ...
            ROIs{ROI_nb(i)}, s_param{i}, STATS.df, ...
            STATS.tstat, p_ttest);

    if model.print2file
        % print to file
        fprintf(model.fid, '%s\n\tt(%i)=%.3f\t%s\t(%s)\n', ...
                ROIs{ROI_nb(i)}, STATS.df, ...
                STATS.tstat, ...
                convert_pvalue(p_ttest, 0), ...
                convert_pvalue(p_perm, 1));
    end

end
