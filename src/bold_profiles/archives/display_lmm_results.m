function display_lmm_results(DO)
    % small script to print out the results of the LMM and run the step down
    % approach (requires the output from
    % - BOLDProfiles/make_figures_BOLD.m or
    % - MVPA/make_figures_MVPA.m
    % also outputs tables (does not serve them with fries though)
    %
    % (C) Copyright 2020 Remi Gau

    % 1. F-test in 2x2 (ROI X shape parameters)
    %   if significant
    %       2. F-test (or one sided t-test if apriori hypothesis) in 1x2
    %       (across ROIs)
    %       3. followed by t-test if signficant
    %
    % - Remove all t-test p-values from figures
    % - Report in tables
    % - Do the whole thing parametrically (even for MVPA) and after checking that
    % the same results are obtained with t-test and sign perm test
    % (reporting the two in a supplementary table if necessary)
    %
    % FYI this is the call to LMM:
    % lme = fitlmematrix(x, Y, Z, G, 'FitMethod', 'REML',...
    %     'FixedEffectPredictors',...
    %     {'ROI1_cst', 'ROI1_lin', 'ROI2_cst', 'ROI2_lin'},...
    %     'RandomEffectPredictors',...
    %     {{'Intercept'}},...
    %     'RandomEffectGroups',...
    %     {'Subject'});

    clear;
    close all;
    clc;

    %% Things to change for each user
    CodeFolder = '/home/remi/github/AV-Attention-7T_code';

    %%
    if nargin < 1 || isempty(DO)
        DO = 2; % 1 BOLD ; 2 MVPA
    end

    FigureFolder = fullfile(CodeFolder, 'Figures');

    % in case it is not running on remi's computer
    if ~exist(FigureFolder, 'dir')
        FigureFolder = pwd;
    end

    NbSubj = 11;
    pattern.screen = '\n%s\t F(%i,%i)= %f\t p = %f\n';
    pattern.file = '\n%s\n\tF(%i,%i)=%.3f\t%s\n';

    switch DO
        case 1
            % Models BOLD
            % 1 - [A-fix]_{Att_A, Att_V} - A1 - PT
            % 4 - [V-fix]_{Att_A, Att_V} - V1 - V2-3
            % 3 - [V-fix]_{Att_A, Att_V} - A1 - PT
            % 2 - [A-fix]_{Att_A, Att_V} - V1 - V2-3
            % 5 - [AV - A]_{Att_A, Att_V} - A1 - PT
            % 8 - [AV - V]_{Att_A, Att_V} - V1 - V2-3
            % 9 - [Att_V - Att_A]_{A, V, AV} - A1 - PT
            % 10 - [Att_V - Att_A]_{A, V, AV} - V1 - V2-3

            load(fullfile(FigureFolder, 'LMM_BOLD_results.mat'), 'models');
            model_of_interest = [1 4 3 2 5 8 9 10];
            % results file
            SavedTxt = fullfile(FigureFolder, 'LMM_BOLD_results.tsv');
        case 2
            % Models MVPA
            % 1 - [AV VS A]_{att A, att V} - A1 - PT
            % 4 - [AV VS V]_{att A, att V} - V1 - V2-3
            % 5 - [Att_A VS Att_V]_{A, V, AV} - A1 - PT
            % 6 - [Att_A VS Att_V]_{A, V, AV} - V1 - V2-3
            load(fullfile(FigureFolder, 'LMM_MVPA_results.mat'), 'models');
            model_of_interest = [1 4:6];
            % results file
            SavedTxt = fullfile(FigureFolder, 'LMM_MVPA_results.tsv');
    end

    fid = fopen (SavedTxt, 'w');

    %% print out results
    ToPermute = list_permutation();

    for i_model = 1:numel(models) % model_of_interest %

        model = models(i_model);

        % print out results
        fprintf('\n%s %i - %s - %s', '%', i_model, model.name, model.ROIs);
        fprintf(fid, '\n%s\n%s', model.name, model.ROIs);
        %     disp(model.lme)

        %     % display reults perm test and t-test for each s parameter for each ROI
        %     fprintf('\n')
        %     for i = 1:4
        %         model.print2file = 0;
        %         compare_results(i, model, ToPermute);
        %     end
        %     clear i
        %     fprintf('\n')

        % effect of either linear or constant in mean of ROIs
        c = [ ...
             1 0 1 0; ...
             0 1 0 1];

        message = 'effect of either linear or constant in mean of ROIs';
        PVAL = test_and_print(model, c, pattern, message, fid);

        %  run LMM on just the CST or LIN from both ROIs if signiicant
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
                        name_param = {'ROI1_cst', 'ROI2_cst'};
                        reg_of_interest = [1 3];
                        submodel.s_param = {'cst', 'cst'};
                    case 2
                        name_param = {'ROI1_lin', 'ROI2_lin'};
                        reg_of_interest = [2 4];
                        submodel.s_param = {'lin', 'lin'};
                end

                Y = model.Y(any(model.X(:, reg_of_interest), 2));

                submodel.lme = fitlmematrix(X, Y, Z, G, 'FitMethod', 'REML', ...
                                            'FixedEffectPredictors', ...
                                            name_param, ...
                                            'RandomEffectPredictors', ...
                                            {{'Intercept'}}, ...
                                            'RandomEffectGroups', ...
                                            {'Subject'});

                submodel.test_side = {model.test_side{i_s_param}};

                submodel.print2file = 1;
                submodel.fid = fid;
                submodel.ROIs = strsplit(model.ROIs, ' - ');
                submodel.X = X;
                submodel.Y = Y;
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

                        p_str = convert_pvalue(PVAL, 0);
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

        fprintf('\n');
        fprintf(fid, '\n');

    end

    fclose (fid);

end

function [PVAL, F, DF1, DF2] = test_and_print(model, c, pattern, message, fid)
    [PVAL, F, DF1, DF2] = coefTest(model.lme, c);
    fprintf(pattern.screen, ...
            message, ...
            DF1, DF2, ...
            F, PVAL);

    fprintf(fid, pattern.file, ...
            message, ...
            DF1, DF2, ...
            F, convert_pvalue(PVAL, 0));

end

function ToPermute = list_permutation()
    % create permutations for exact sign permutation test
    for iSubj = 1:11
        sets{iSubj} = [-1 1];
    end
    [a, b, c, d, e, f, g, h, i, j, k] = ndgrid(sets{:});
    clear sets;
    ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:), k(:)];
end

function Perms = create_null_distribution(ToPermute, Betas)
    for iPerm = 1:size(ToPermute, 1)
        tmp2 = ToPermute(iPerm, :)';
        Perms(iPerm, :) = mean(Betas .* repmat(tmp2, 1, size(Betas, 2))); %#ok<*AGROW>
    end
end

function P = perm_test(betas, side, perms)
    if strcmp(side, 'left')
        P = sum(perms < mean(betas)) / numel(perms);

    elseif strcmp(side, 'right')
        P = sum(perms > mean(betas)) /  numel(perms);

    elseif strcmp(side, 'both')
        P = sum(abs(perms) > abs(mean(betas))) / numel(perms);
    end
end

function [p_perm, p_ttest] = compare_results(i, model, ToPermute)

    NbSubj = 11;

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
    perms = create_null_distribution(ToPermute, betas);

    p_perm = perm_test(betas, side, perms);
    [~, p_ttest, ~, STATS] = ttest(betas, 0, 'tail', side);

    % display the results of perm and t-test
    fprintf('%s %s\t t(%i) = %f \t p = %f \t (p_perm = %f)\n', ...
            ROIs{ROI_nb(i)}, s_param{i}, STATS.df, ...
            STATS.tstat, p_ttest, p_perm);

    if model.print2file
        % print to file
        fprintf(model.fid, '%s\n\tt(%i)=%.3f\t%s\t(%s)\n', ...
                ROIs{ROI_nb(i)}, STATS.df, ...
                STATS.tstat, ...
                convert_pvalue(p_ttest, 0), ...
                convert_pvalue(p_perm, 1));
    end

    % OVERKILL: use LMM to do a t-test to make sure we get the same
    % thing
    lme = fitlmematrix(ones(NbSubj, 1), betas, ones(NbSubj, 1), [1:NbSubj]', 'FitMethod', 'REML', ...
                       'FixedEffectPredictors', ...
                       {'s_param'}, ...
                       'RandomEffectPredictors', ...
                       {{'Intercept'}}, ...
                       'RandomEffectGroups', ...
                       {'Subject'});
    % disp(lme.Coefficients)

end

function p_str = convert_pvalue(p, p_perm)
    if p_perm
        p_str = 'p_perm';
    else
        p_str = 'p';
    end
    if p < 0.001
        p_str = [p_str '<0.001'];
    else
        p_str = sprintf('%s=%.3f', p_str, p);
    end
end
