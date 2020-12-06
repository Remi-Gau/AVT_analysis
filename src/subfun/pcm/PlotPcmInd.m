% (C) Copyright 2020 Remi Gau
function  fig_handles = PlotPcmInd(M, G, G_hat, T_ind, D, theta_ind, G_pred_ind, G_pred_ind_CV, RDMs_CV, opt)

    COLOR_SUBJECTS = SubjectColours();

    ColorMap = brain_colour_maps('hot_increasing');

    c = pcm_indicatorMatrix('allpairs', 1:size(M{1}.Ac, 1));

    fontsize = 6;

    NbSub = numel(T_ind.SN);

    % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
    H = 1;

    %% Plot likelihood of each subject with his empirical and predicted G matrices
    for iSub = 1:NbSub

        fig_handles(iSub) = figure( ...
                                   'name', [opt.SubLs(iSub).name '-' opt.FigName], ...
                                   'Position', opt.FigDim, ...
                                   'Color', [1 1 1]);

        iSubplot = numel(M) * 2 + 1;

        %% G_{emp}
        subplot(6, numel(M), iSubplot:iSubplot + 1);

        imagesc(H * G_hat(:, :, iSub) * H');

        iSubplot = SetAxisMatrix(iSubplot, ColorMap);
        iSubplot = iSubplot + 1;

        t = xlabel('G_{emp}');
        set(t, 'fontsize', 8);

        t = ylabel('CV');
        set(t, 'fontsize', 12);

        %% CVed G_{pred} free model
        subplot(6, numel(M), iSubplot:iSubplot + 1);

        imagesc(H * mean(G_pred_ind_CV{end}, 3) * H');

        iSubplot = SetAxisMatrix(iSubplot, ColorMap);
        iSubplot = iSubplot + 1;

        t = xlabel('G_{pred} free');
        set(t, 'fontsize', 8);

        %% plot the CVed G_{pred} of each model
        for iM = 2:numel(M) - 1

            subplot(6, numel(M), iSubplot:iSubplot + 1);

            imagesc(H * mean(G_pred_ind_CV{iM}, 3) * H');

            iSubplot = SetAxisMatrix(iSubplot, ColorMap);
            iSubplot = iSubplot + 1;

            t = xlabel(['G_{pred} ' num2str(M{iM}.name)]);
            set(t, 'fontsize', 9);

        end

        iSubplot = numel(M) * 4 + 1;

        %% RDM or MDS or non CV G
        subplot(6, numel(M), iSubplot:iSubplot + 1);

        imagesc(H * G(:, :, iSub) * H');

        iSubplot = SetAxisMatrix(iSubplot, ColorMap);
        iSubplot = iSubplot + 1;

        t = xlabel('G_{emp}');
        set(t, 'fontsize', 8);
        t = ylabel('No CV');
        set(t, 'fontsize', 12);

        %% G_{pred} free model
        subplot(6, numel(M), iSubplot:iSubplot + 1);

        imagesc(H * G_pred_ind{end}(:, :, iSub) * H');

        iSubplot = SetAxisMatrix(iSubplot, ColorMap);
        iSubplot = iSubplot + 1;

        t = xlabel('G_{pred} free');
        set(t, 'fontsize', 8);

        %% plot the G_{pred} of each model
        for iM = 2:numel(M) - 1

            subplot(6, numel(M), iSubplot:iSubplot + 1);

            imagesc(H * G_pred_ind{iM}(:, :, iSub) * H');

            iSubplot = SetAxisMatrix(iSubplot, ColorMap);
            iSubplot = iSubplot + 1;

            t = xlabel(['G_{pred} ' num2str(M{iM}.name)]);
            set(t, 'fontsize', 9);

            labels{iM - 1} = M{iM}.name;
        end

        %% Provide a plot of the crossvalidated likelihoods
        tmp = numel(M) / 3;
        for i = 1:3

            Upperceil = T_ind.likelihood(iSub, end);
            if i == 1
                Data2Plot = T_ind;
                SubPlotRange = [1:floor(tmp) (numel(M) + 1):(numel(M) + (floor(tmp)))];
                Title = 'NoCV';
                Upperceil = Data2Plot.likelihood(iSub, end);

            elseif i == 2
                Data2Plot = D;
                SubPlotRange = [1 * floor(tmp + 1):2 * floor(tmp) numel(M) + (1 * floor(tmp + 1):2 * floor(tmp))];
                Title = 'CV';

            elseif i == 3 %
                Data2Plot = T_ind;
                SubPlotRange = [2 * floor(tmp + 1):3 * floor(tmp) numel(M) + (2 * floor(tmp + 1):3 * floor(tmp))];
                Title = 'AIC: ln(L_{NoCV})-k';
                for iM = 1:size(Data2Plot.likelihood, 2)
                    Data2Plot.likelihood(iSub, iM) = ...
                        -1 * ((M{iM}.numGparams + 2) - Data2Plot.likelihood(iSub, iM)); % -AIC/2
                end

            end

            subplot(6, numel(M), SubPlotRange);
            hold on;

            T = pcm_plotModelLikelihood(Data2Plot, M, ...
                                        'upperceil', Upperceil, ...
                                        'colors', opt.colors, ...
                                        'normalize', 0, ...
                                        'subj', iSub);

            set(gca, 'XTick', 1:numel(M) - 2);
            set(gca, 'XTickLabel', labels);

            if i > 1
                ylabel('');
                set(gca, 'yaxislocation', 'right');
            end

            MIN = min(T.likelihood_norm);
            MAX = max(T.likelihood_norm);
            %         MAX = max([MAX Upperceil*-1]);

            ax = axis;
            if MIN > 0
                MIN = 0;
            end

            axis([ax(1) ax(2) MIN MAX]);

            title(Title);
        end

        mtit(fig_handles(iSub).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

    end

    %% Plot empirical and predicted G matrices with CV / no CV and with centering and no centering
    fig_handles(end + 1) = figure( ...
                                  'name', ['G_{pred-free}&G_{emp}--' opt.FigName], ...
                                  'Position', opt.FigDim, 'Color', [1 1 1]);

    iSubplot = 1;

    for iSub = 1:NbSub

        for Centering = 0:1

            H = eye(size(M{1}.Ac, 1)) - ones(size(M{1}.Ac, 1)) / size(M{1}.Ac, 1);
            if ~Centering
                H = 1;
            end

            %% non CV G_emp
            subplot(NbSub, 8, iSubplot);

            imagesc(H * G(:, :, iSub) * H');

            box off;
            axis on;
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);

            if iSub == 1
                t = title('G_{emp}');
                set(t, 'fontsize', 6);
            end

            if Centering == 0
                t = ylabel(opt.SubLs(iSub).name);
                set(t, 'fontsize', 6);
            end

            %% CV G_emp
            subplot(NbSub, 8, iSubplot);

            imagesc(H * G_hat(:, :, iSub) * H');

            box off;
            axis on;
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);

            if iSub == 1
                t = title('G_{emp}-CV');
                set(t, 'fontsize', 6);
            end

            % G_{pred} free model
            subplot(NbSub, 8, iSubplot);

            imagesc(H * G_pred_ind{end}(:, :, iSub) * H');
            box off;
            axis on;
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);

            if iSub == 1
                t = title('free G_{pred}');
                set(t, 'fontsize', 6);
            end

            % G_{pred} free model
            subplot(NbSub, 8, iSubplot);

            imagesc(H * G_pred_ind_CV{end}(:, :, iSub) * H');
            box off;
            axis on;
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);

            if iSub == 1
                t = title('free G_{pred}-CV');
                set(t, 'fontsize', 6);
            end

        end

    end

    mtit(fig_handles(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

    %% Plot likelihood as a group
    fig_handles = figure( ...
                         'name', opt.FigName, ...
                         'Position', opt.FigDim, ...
                         'Color', [1 1 1]);

    subplot(121);

    T = pcm_plotModelLikelihood( ...
                                T_ind, ...
                                M, ...
                                'upperceil', T_ind.likelihood(:, end), ...
                                'colors', opt.colors, ...
                                'normalize', 0);

    set(gca, 'fontsize', 6);

    PlotPcmSubjects(M, T, opt, mean(T_ind.likelihood(:, end) - T_ind.likelihood(:, 1)));

    title('no CV');

    subplot(122);

    T = pcm_plotModelLikelihood(D, M, ...
                                'upperceil', T_ind.likelihood(:, end), ...
                                'colors', opt.colors, ...
                                'normalize', 0);
    set(gca, 'fontsize', 6);

    PlotPcmSubjects(M, T, opt, mean(T_ind.likelihood(:, end) - T_ind.likelihood(:, 1)));

    title('CV');

    mtit(strrep(opt.FigName, '_', ' '), 'fontsize', 12, 'xoff', 0, 'yoff', .035);

    for iM = 2:numel(M) - 1

        %% Plot RDM estimated from G_{emp} and results from the RSA toolbox

        if iM == 2

            [nVerPan, nHorPan] = rsa.fig.paneling(NbSub);

            for i = 1:2

                if i == 1
                    Rank_trans = 'ranktrans-';
                else
                    Rank_trans = 'raw-';
                end

                fig_handles(end + 1) = figure( ...
                                              'name', ['RDM_{PCM}-' Rank_trans  opt.FigName], ...
                                              'Position', opt.FigDim, ...
                                              'Color', [1 1 1]);

                iSubplot = 1;
                for iSub = 1:NbSub
                    subplot(nVerPan, nHorPan, iSubplot);
                    RDM = squareform(diag(c * G_hat(:, :, iSub) * c'));
                    if i == 1
                        RDM = rsa.util.rankTransform_equalsStayEqual(RDM, 1);
                    end
                    imagesc(RDM);
                    colorbar;
                    iSubplot = SetAxisMatrix(iSubplot, ColorMap);
                    t = title(opt.SubLs(iSub).name);
                    set(t, 'fontsize', fontsize + 2);
                end
                mtit(fig_handles(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

                fig_handles(end + 1) = figure( ...
                                              'name', ['RDM_{RSA}-' Rank_trans opt.FigName], ...
                                              'Position', opt.FigDim, ...
                                              'Color', [1 1 1]);

                iSubplot = 1;
                for iSub = 1:NbSub
                    subplot(nVerPan, nHorPan, iSubplot);
                    RDM = RDMs_CV(:, :, iSub);
                    if i == 1
                        RDM = rsa.util.rankTransform_equalsStayEqual(RDM, 1);
                    end
                    imagesc(RDM);
                    colorbar;
                    iSubplot = SetAxisMatrix(iSubplot, ColorMap);
                    t = title(opt.SubLs(iSub).name);
                    set(t, 'fontsize', fontsize + 2);
                end

                mtit(fig_handles(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

            end
        end

        %% Plot RDM estimated from G_{pred}
        [nVerPan, nHorPan] = rsa.fig.paneling(NbSub);

        NbSub = numel(T.SN);

        fig_handles(end + 1) = figure( ...
                                      'name', ['RDMs_{pred}-Model-' M{iM}.name  '--'  opt.FigName], ...
                                      'Position', opt.FigDim, 'Color', [1 1 1]);

        iSubplot = 1;
        for iSub = 1:NbSub
            subplot(nVerPan, nHorPan, iSubplot);
            RDM = squareform(diag(c * G_pred_ind{iM}(:, :, iSub) * c'));
            RDM = rsa.util.rankTransform_equalsStayEqual(RDM, 1);
            imagesc(RDM);
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);
            t = title(opt.SubLs(iSub).name);
            set(t, 'fontsize', fontsize + 2);
        end
        mtit(fig_handles(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

        %% Plot theta estimates and each subject's empirical G matrix, as well as the predicted one and the free model one
        H = 1;
        % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);

        fig_handles(end + 1) = figure( ...
                                      'name', ['Model-' M{iM}.name  '--'  opt.FigName], ...
                                      'Position', opt.FigDim, ...
                                      'Color', [1 1 1]);

        Val2Plot = 1:M{iM}.numGparams;
        MEAN = mean(theta_ind{iM}(Val2Plot, :), 2);
        SEM = nansem(theta_ind{iM}(Val2Plot, :), 2);

        subplot(NbSub, 6, repmat([1:3], NbSub, 1) + repmat(6 * (0:NbSub - 1)', 1, 3));
        hold on;
        t = errorbar(Val2Plot - .1, MEAN, SEM, ' .k');
        set(t, 'MarkerSize', 10);

        for iVal = Val2Plot
            for iSub = 1:NbSub
                plot(iVal + .1 + opt.scatter(iSub), ...
                     theta_ind{iM}(iVal, iSub), ...
                     'linestyle', 'none', ...
                     'Marker', '.', ...
                     'MarkerEdgeColor', COLOR_SUBJECTS(iSub, :), ...
                     'MarkerFaceColor', COLOR_SUBJECTS(iSub, :), ...
                     'MarkerSize', 28);
            end
        end

        plot([0.5 M{iM}.numGparams + .5], [0 0], '-- k');

        axis tight;
        grid on;
        set(gca, ...
            'Xtick', 1:M{iM}.numGparams, ...
            'Xticklabel', 1:M{iM}.numGparams);

        xlabel('Features');
        title('theta estimages (No CV)');

        iSubplot = 4;
        for iSub = 1:NbSub

            %%
            subplot(NbSub, 6, iSubplot);

            imagesc(H * G_hat(:, :, iSub) * H');

            iSubplot = SetAxisMatrix(iSubplot, ColorMap);
            if iSub == 1
                t = title('G_{emp}');
                set(t, 'fontsize', fontsize + 2);
            end
            t = ylabel(opt.SubLs(iSub).name);
            set(t, 'fontsize', fontsize);

            %%
            subplot(NbSub, 6, iSubplot);

            imagesc(H * G_pred_ind_CV{iM}(:, :, iSub) * H');
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);
            if iSub == 1
                t = title('G_{pred} CV');
                set(t, 'fontsize', fontsize + 2);
            end

            %%
            subplot(NbSub, 6, iSubplot);

            %         RDM = squareform(diag(c*G_pred_ind{iM}(:,:,iSub)*c'));
            %         RDM = rsa.util.rankTransform_equalsStayEqual(RDM,1);
            %         imagesc(RDM)
            imagesc(H * G_pred_ind_CV{end}(:, :, iSub) * H');
            iSubplot = SetAxisMatrix(iSubplot, ColorMap);
            if iSub == 1
                %             t=title('RDM_{pred}');
                t = title('G_{free CV}');
                set(t, 'fontsize', fontsize + 2);
            end

            iSubplot = iSubplot + 3;
        end

        mtit(fig_handles(end).Name, ...
             'fontsize', 12, ...
             'xoff', 0, ...
             'yoff', .035);

    end

end

function PlotPcmSubjects(M, T, opt, upperceil)

    hold on;

    COLOR_SUBJECTS = SubjectColours();

    for iM = 2:numel(M) - 1

        %             h = plotSpread(T.likelihood_norm(:,iM), ...
        %                 'distributionIdx', ones(size(T.likelihood_norm(:,iM))), ...
        %                 'distributionMarkers', {'o'},...
        %                 'distributionColors', {'w'}, ...
        %                 'xValues', iM - 0.8, ...
        %                 'binWidth', 1, ...
        %                 'spreadWidth', 0.2);
        %             set(h{1}, 'MarkerSize', 5, ...
        %                 'MarkerEdgeColor', 'k', ...
        %                 'MarkerFaceColor', 'w', ...
        %                 'LineWidth', 1)

        labels{iM - 1} = M{iM}.name;

        for iSubj = 1:numel(T.SN)
            plot(iM - 0.8 + opt.scatter(iSubj), ...
                 T.likelihood_norm(iSubj, iM), ...
                 'linestyle', 'none', ...
                 'Marker', '.', ...
                 'MarkerEdgeColor', COLOR_SUBJECTS(iSubj, :), ...
                 'MarkerFaceColor', COLOR_SUBJECTS(iSubj, :), ...
                 'MarkerSize', 28);
        end

    end

    MIN = min(min(T.likelihood_norm(:, 2:end - 1)));
    MAX = max(max(T.likelihood_norm(:, 2:end - 1)));
    MAX = max([MAX upperceil]);

    ax = axis;
    if MIN > 0
        MIN = 0;
    end

    axis([ax(1) ax(2) MIN MAX]);

    set(gca, 'XTick', 1:numel(M) - 2);
    set(gca, 'XTickLabel', labels);
    set(gca, 'fontsize', 8);

end

function SubPlot = SetAxisMatrix(SubPlot, ColorMap)
    box off;
    axis square;
    set(gca, ...
        'Xtick', [], ...
        'Ytick', []);
    colormap(ColorMap);

    SubPlot = SubPlot + 1;
end
