% run LMM on just the CST or LIN from both ROIs if signiicant
if PVAL < .05

    X = [ ...
         [ones(NbSubj, 1); zeros(NbSubj, 1)], ... % reg 1 : ROI1 cst
         [zeros(NbSubj, 1); ones(NbSubj, 1)]]; % reg 1 : ROI1 lin
    Z = repmat(ones(NbSubj, 1), 2, 1);
    G = repmat([1:NbSubj]', 2, 1);

    % loop over cst and lin
    for i_s_param = 1:2

        switch i_s_param
            case 1
                submodel.s_param = {'cst'};
            case 2
                submodel.s_param = {'lin'};
        end

        Y = model.Y(any(model.X(:, reg_of_interest), 2));

        model = FitLmm(model);

        c = [1 1];

        message = ['effect of ' submodel.s_param{i_s_param} ' averaged across ROIs'];

        switch submodel.test_side{1}
            case 'both'

                PVAL = test_and_print(submodel, c, pattern, message, fid);

            otherwise

                Y = [Y(logical(X(:, 1))), Y(logical(X(:, 2)))];
                Y = mean(Y, 2);

                [~, PVAL, ~, STATS] = ttest(Y, 0, 'tail', submodel.test_side{1});

                % display the results of perm and t-test
                fprintf('effect of mean(%s, %s) %s\t t(%i) = %f \t p = %f\n', ...
                        submodel.ROIs{1}, submodel.ROIs{2}, submodel.s_param{1}, STATS.df, ...
                        STATS.tstat, PVAL);

                p_str = convert_pvalue(PVAL);
                fprintf(submodel.fid, 'mean(%s, %s)\n\tt(%i)=%.3f\t%s\n', ...
                        submodel.ROIs{1}, submodel.ROIs{2}, STATS.df, STATS.tstat, p_str);

        end

        if PVAL < .05
            fprintf('effect within ROI\n');
            fprintf(fid, 'effect within ROI\n');
            for iROI = 1:2
                compare_results(iROI, submodel, ToPermute);
            end
            fprintf('\n');
        end
    end

end
