clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
cd (StartDir);

Get_dependencies('/home/rxg243/Dropbox');
Get_dependencies('D:\Dropbox\');

ResultsDir = fullfile(StartDir, 'results', 'SVM');
FigureFolder = fullfile(StartDir, 'figures', 'SVM', 'surf');

addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

NbLayers = 6;

% Options for the SVM
[opt, ~] = get_mvpa_options();

SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);

fontsize = 8;

%% Gets data for each subject
SubLs = dir('sub*');
NbSub = numel(SubLs);

% ROI
ROIs(1) = struct('name', 'V1');
ROIs(end + 1) = struct('name', 'V2');
ROIs(end + 1) = struct('name', 'V3');
ROIs(end + 1) = struct('name', 'V4');
ROIs(end + 1) = struct('name', 'V5');

ROIs(end + 1) = struct('name', 'A1');
ROIs(end + 1) = struct('name', 'PT');

% Analysis
SVM(1) = struct('name', 'A VS T Ipsi', 'ROI', 1);
SVM(end + 1) = struct('name', 'V VS T Ipsi', 'ROI', 6);

SVM(end + 1) = struct('name', 'A VS T Contra', 'ROI', 1);
SVM(end + 1) = struct('name', 'V VS T Contra', 'ROI', 6);

for i = 1:numel(SVM)
    SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI).name}); %#ok<*AGROW>
end

for iSubj = 1:NbSub
    fprintf('\n\nProcessing %s', SubLs(iSubj).name);

    SubDir = fullfile(StartDir, SubLs(iSubj).name);
    SaveDir = fullfile(SubDir, 'results', 'SVM');

    for iSVM = 1:numel(SVM)
        fprintf('\n Running SVM:  %s', SVM(iSVM).name);

        for iROI = 1:numel(SVM(iSVM).ROI)

            File2Load = fullfile(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]));

            if exist(File2Load, 'file')

                load(File2Load, 'Results');

                % Extract results
                Perms = Results.session(end).rand.perm;

                for iPerm = 1:numel(Perms)
                    CV = Results.session(end).rand.perm(iPerm).CV;
                    if iPerm == 1
                        SVM(iSVM).ROI(iROI).grp(iSubj) = mean([CV.acc]);
                    end
                    SVM(iSVM).ROI(iROI).perms(iPerm, iSubj) = mean([CV.acc]);
                end

            else
                warning('\nThe file %s was not found.', File2Load);
                SVM(iSVM).ROI(iROI).perms(iSubj, :) = nan(1000, 1);
                SVM(iSVM).ROI(iROI).grp(iSubj) = nan(1);
            end
            clear Results;

            File2Load = strrep(File2Load, '_perm-1', '');
            if exist(File2Load, 'file')
                load(File2Load, 'Results');
                SVM(iSVM).ROI(iROI).grp_no_perm(iSubj) = ...
                    mean([Results.session(end).rand.perm(1).CV.acc]);
            else
                warning('\nThe file %s was not found.', File2Load);
                SVM(iSVM).ROI(iROI).grp_no_perm(iSubj) = nan(1);
            end
            clear Results;

        end

    end
end

%% Saves
save(fullfile(StartDir, 'results', 'SVM', ['GrpPool' SaveSufix]), 'SVM');

%% Plot null distribtution and the different p-values
close all;
clc;

NbMCPerm = 10^6;

load(fullfile(StartDir, 'results', 'SVM', ['GrpPool' SaveSufix]), 'SVM');

NbSub = numel(SVM(1).ROI(1).grp);

sets = {};
for iSub = 1:NbSub
    sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

for iSVM = 1:numel(SVM)
    fprintf('\nRunning SVM:  %s\n', SVM(iSVM).name);

    for iROI = 1:numel(SVM(iSVM).ROI)

        fprintf('\n Running ROI:  %s\n', SVM(iSVM).ROI(iROI).name);

        clear tmp Grp_lvl_btstrp_perms SignPerms;

        % null distribution a la Seltzer (Monte Carlo)
        tmp = SVM(iSVM).ROI(iROI).perms;
        for iPerm = 1:NbMCPerm
            IND = sub2ind(size(tmp), randi(size(tmp, 1), 1, size(tmp, 2)), 1:size(tmp, 2));
            Grp_lvl_btstrp_perms(iPerm, 1) = mean(tmp(IND)); %#ok<*SAGROW>
        end

        % Prevalence test
        % a:            three-dimensional array of test statistic values
        %               (voxels x subjects x first-level permutations)
        %               a(:, :, 1) must contain actual values
        a = SVM(iSVM).ROI(iROI).perms';
        a = reshape(a, [1, size(a, 1), size(a, 2)]);
        [results, params] = prevalenceCore(a, NbMCPerm, 0.05);

        % null distribution sign permutation
        tmp = SVM(iSVM).ROI(iROI).grp;
        tmp = tmp - .5;
        tmp2 = SVM(iSVM).ROI(iROI).grp_no_perm;
        tmp2 = tmp2 - .5;
        for iPerm = 1:size(ToPermute, 1)
            tmp3 = ToPermute(iPerm, :);
            SignPerms_grp(iPerm, :) = mean(tmp .* tmp3); %#ok<*SAGROW>
            SignPerms_grp_no_perm(iPerm, :) = mean(tmp2 .* tmp3); %#ok<*SAGROW>
        end

        % plot
        fig = figure('Name', [SVM(iSVM).name ' - ' SVM(iSVM).ROI(iROI).name], 'Position', [100, 50, 1200, 700], 'Color', [1 1 1], 'Visible', 'on');

        % plot the null distribution with Monte Carlo
        % gives the p values of the global and majority prevalence test
        % gives the p values of the exact fixed effect permutation test
        SubPlot = [1:3 6:8];
        subplot(4, 5, SubPlot);
        hold on;

        tmp = hist(Grp_lvl_btstrp_perms, 100);
        MAX = max(tmp);
        hist(Grp_lvl_btstrp_perms, 100, 'b');

        plot(repmat(mean(SVM(iSVM).ROI(iROI).grp), 1, 2), ...
             [0 MAX], '-r', 'linewidth', 2);
        plot(repmat(mean(SVM(iSVM).ROI(iROI).grp_no_perm), 1, 2), ...
             [0 MAX], '--r', 'linewidth', 2);

        axis([0.35 0.65 0 MAX]);

        t = title(sprintf('Null distribution:\nMonte Carlo'));
        set(t, 'fontsize', fontsize);

        t = text(0.4, MAX, sprintf('p_{prev-glob}=%.3f ', results.puGN));
        set(t, 'fontsize', fontsize);

        t = text(0.4, MAX - MAX * .1, sprintf('p_{prev-maj}=%.3f ', results.puMN));
        set(t, 'fontsize', fontsize);

        P = sum(Grp_lvl_btstrp_perms - .5 > mean(SVM(iSVM).ROI(iROI).grp - .5)) / size(Grp_lvl_btstrp_perms, 1);
        t = text(0.4, MAX - MAX * .2, sprintf('p_{MC-perm}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        % plot the null distribution sign permutation based on accuracies
        % obtained with fewer CV
        % gives the p values of the exact sign permutation test
        % gives the binomial test p value
        % gives the t-test p value
        SubPlot = [4 9];
        subplot(4, 5, SubPlot);
        hold on;

        tmp = hist(mean(SignPerms_grp, 2), 100);
        MAX = max(tmp) * 1.1;
        hist(mean(SignPerms_grp, 2), 100, 'b');

        plot(repmat(mean(SVM(iSVM).ROI(iROI).grp), 1, 2) - .5, ...
             [0 MAX], '-r', 'linewidth', 2);

        axis([-0.1 0.1 0 MAX * 1.1]);

        t = title(sprintf('Null distribution (25 CVs):\nsign permutation'));
        set(t, 'fontsize', fontsize);

        P = sum(mean(SignPerms_grp, 2) > mean(SVM(iSVM).ROI(iROI).grp - .5)) / size(SignPerms_grp, 1);
        t = text(-0.09, MAX, sprintf('p_{sign-perm}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        P = myBinomTest(sum(SVM(iSVM).ROI(iROI).grp > .5), 10, .5, 'one');
        t = text(-0.09, MAX * .925, sprintf('p_{binomial}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        [~, P] = ttest(SVM(iSVM).ROI(iROI).grp - .5, 0, 'tail', 'right');
        t = text(-0.09, MAX * .85, sprintf('p_{ttest}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        % plot the null distribution sign permutation
        % gives the p values of the exact sign permutation test
        % gives the binomial test p value
        % gives the t-test p value
        SubPlot = [5 10];
        subplot(4, 5, SubPlot);
        hold on;

        tmp = hist(mean(SignPerms_grp_no_perm, 2), 100);
        MAX = max(tmp) * 1.1;
        hist(mean(SignPerms_grp_no_perm, 2), 100, 'b');

        plot(repmat(mean(SVM(iSVM).ROI(iROI).grp_no_perm), 1, 2) - .5, ...
             [0 MAX], '--r', 'linewidth', 2);

        axis([-0.1 0.1 0 MAX * 1.1]);

        t = title(sprintf('Null distribution (200 CVs):\nsign permutation'));
        set(t, 'fontsize', fontsize);

        P = sum(mean(SignPerms_grp_no_perm, 2) > mean(SVM(iSVM).ROI(iROI).grp_no_perm - .5)) / size(SignPerms_grp_no_perm, 1);
        t = text(-0.09, MAX, sprintf('p_{sign-perm}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        P = myBinomTest(sum(SVM(iSVM).ROI(iROI).grp_no_perm > .5), 10, .5, 'one');
        t = text(-0.09, MAX * .925, sprintf('p_{binomial}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        [~, P] = ttest(SVM(iSVM).ROI(iROI).grp_no_perm - .5, 0, 'tail', 'right');
        t = text(-0.09, MAX * 0.85, sprintf('p_{ttest}=%.3f ', P));
        set(t, 'fontsize', fontsize);

        % plot the subjects null distribution of the label permutations
        % gives the p values of the exact label permutation test
        SubPlot = 11;

        MAX = [];
        for iSubj = 1:NbSub
            MAX = max([MAX max(hist(SVM(iSVM).ROI(iROI).perms(:, iSubj), 100))]);
        end
        MAX = MAX + MAX * .2;

        for iSubj = 1:NbSub
            subplot(4, 5, SubPlot);
            hold on;

            hist(SVM(iSVM).ROI(iROI).perms(:, iSubj), 100, 'k');

            plot([SVM(iSVM).ROI(iROI).grp(iSubj) SVM(iSVM).ROI(iROI).grp(iSubj)], ...
                 [0 MAX], '-r', 'linewidth', 2);
            plot([SVM(iSVM).ROI(iROI).grp_no_perm(iSubj) SVM(iSVM).ROI(iROI).grp_no_perm(iSubj)], ...
                 [0 MAX], '--r', 'linewidth', 2);

            axis([0.2 0.8 0 MAX]);

            t = title(SubLs(iSubj).name);
            set(t, 'fontsize', fontsize);

            P = sum(SVM(iSVM).ROI(iROI).perms(:, iSubj) > SVM(iSVM).ROI(iROI).grp(iSubj)) / numel(SVM(iSVM).ROI(iROI).perms(:, iSubj));
            t = text(0.25, MAX - MAX * .1, sprintf('p_{label-perm}=%.3f ', P));
            set(t, 'fontsize', fontsize);

            set(gca, 'tickdir', 'out', 'xtick', 0:.1:1, ...
                'xticklabel', 0:.1:1, 'ticklength', [0.01 0.01], ...
                'fontsize', fontsize);

            SubPlot = SubPlot + 1;
        end

        mtit(fig.Name, 'xoff', 0, 'yoff', +0.03, 'fontsize', fontsize);

        print(gcf, fullfile(FigureFolder, ['Grp_Lvl_Perm_' strrep(fig.Name, ' ', '-')]), ...
              '-dtiff');

    end
end

%% Get all the CV when no permutation is done at the subject level
for iSVM = 1:numel(SVM)
    for iROI = 1:numel(SVM(iSVM).ROI)
        for iSubj = 1:NbSub
            SubDir = fullfile(StartDir, SubLs(iSubj).name);
            SaveDir = fullfile(SubDir, 'results', 'SVM');

            File2Load = fullfile(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]));
            File2Load = strrep(File2Load, '_perm-1', '');

            load(File2Load, 'Results');
            SVM(iSVM).ROI(iROI).grp_no_perm_all_CV{iSubj} = ...
                [Results.session(end).rand.perm(1).CV.acc];
            clear Results;
        end
    end
end

%% Corridor of stability
Nb_CV_to_sample = [15:10:55 75:25:200];
NbPerm = 10^4;
close all;

for iSVM = 1:numel(SVM)
    for iROI = 1:numel(SVM(iSVM).ROI)

        clear Acc;

        for iSubj = 1:NbSub
            for iPerm = 1:NbPerm
                for CV_sampled = 1:numel(Nb_CV_to_sample)
                    clear tmp;
                    tmp = SVM(iSVM).ROI(iROI).grp_no_perm_all_CV{iSubj};
                    Acc(iSubj, CV_sampled, iPerm) = ...
                        mean(tmp(randi(numel(tmp), Nb_CV_to_sample(CV_sampled), 1)));
                end
            end
        end

        fig = figure('Name', ['CoS--' SVM(iSVM).name ' - ' SVM(iSVM).ROI(iROI).name], 'Position', [100, 50, 1200, 700], 'Color', [1 1 1], 'Visible', 'on');

        hold on;

        tmp = squeeze(mean(Acc, 1));
        errorbar(Nb_CV_to_sample, mean(tmp, 2), std(tmp, [], 2), 'k', 'linewidth', 2);

        plot([Nb_CV_to_sample(1) Nb_CV_to_sample(end)], ...
             repmat(mean(SVM(iSVM).ROI(iROI).grp), 1, 2), ...
             '-r', 'linewidth', 2);
        plot([Nb_CV_to_sample(1) Nb_CV_to_sample(end)], ...
             repmat(mean(SVM(iSVM).ROI(iROI).grp_no_perm), 1, 2), ...
             '--r', 'linewidth', 2);

        xlabel('Number of CV / perm at the subject level');

        legend({'CoS', 'grp acc with 200 CV', 'grp acc with 25 CV'});

        mtit(fig.Name, 'xoff', 0, 'yoff', +0.03, 'fontsize', fontsize);

        set(gca, 'xtick', Nb_CV_to_sample, 'xticklabel', Nb_CV_to_sample);

        ax = axis;
        axis([0 210 0.5 ax(4)]);

        print(gcf, fullfile(FigureFolder, [strrep(fig.Name, ' ', '-') '.tif']), ...
              '-dtiff');

    end
end
