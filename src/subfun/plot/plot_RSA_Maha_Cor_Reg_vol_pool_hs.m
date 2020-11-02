function plot_RSA_Maha_Cor_Reg_vol_pool_hs(StartDir, SubLs, beta_type, ranktrans, isplotranktrans)

    Do_hs_Idpdtly = 1;
    if Do_hs_Idpdtly
        hs_sufix = 'lhs';
    else
        hs_sufix = '';
    end

    if nargin < 3 || isempty(beta_type)
        beta_type = 0;
    end
    switch beta_type
        case 0
            Whitened_beta = 0;
            Trim_beta = 0;
        case 1
            Whitened_beta = 1;
            Trim_beta = 0;
        case 2
            Whitened_beta = 0;
            Trim_beta = 1;
    end

    if nargin < 4 || isempty(ranktrans)
        ranktrans = 0;
    end

    if nargin < 5 || isempty(isplotranktrans)
        isplotranktrans = 0;
    end

    ResultsDir = fullfile(StartDir, 'results', 'profiles');
    FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'vol');
    [~, ~, ~] = mkdir(FigureFolder);

    RSA_dir = fullfile(StartDir, 'figures', 'RSA');
    mkdir(RSA_dir, 'Cdt');
    mkdir(fullfile(RSA_dir, 'Cdt', 'Subjects'));

    Reg_dir = fullfile(StartDir, 'figures', 'Regression');
    mkdir(Reg_dir, 'Cdt');
    mkdir(fullfile(Reg_dir, 'Cdt', 'Subjects'));

    Cor_dir = fullfile(StartDir, 'figures', 'Correlation');
    mkdir(Cor_dir, 'Cdt');
    mkdir(fullfile(Cor_dir, 'Cdt', 'Subjects'));

    NbSub = numel(SubLs);

    CondNames = { ...
                 'AStimL', 'AStimR', ...
                 'VStimL', 'VStimR', ...
                 'TStimL', 'TStimR', ...
                 'ATargL', 'ATargR', ...
                 'VTargL', 'VTargR', ...
                 'TTargL', 'TTargR' ...
                };

    ToPlot = {'ROI'};

    ROIs = { ...
            'A1', ...
            'PT', ...
            'V1', ...
            'V2', ...
            'V3', ...
            'V4', ...
            'V5' ...
           };

    ColorMap = brain_colour_maps('hot_increasing');

    FigDim = [100, 100, 1000, 1500];

    if Whitened_beta
        Save_suffix = 'beta-wht'; %#ok<*UNRCH>
        DoTarget = 2;
    elseif Trim_beta
        Save_suffix = 'beta-trim';
        DoTarget = 1;
    else
        Save_suffix = 'beta-raw';
        DoTarget = 2;
    end

    if ranktrans
        ranktrans_suffix = 'ranktrans-1';
    else
        ranktrans_suffix = 'ranktrans-0';
    end

    if isplotranktrans
        plotranktrans_suffix = 'plotranktrans-1';
    else
        plotranktrans_suffix = 'plotranktrans-0';
    end

    % RDMs{iROI,iToPlot,1} Euclidian
    % RDMs{iROI,iToPlot,2} Spearman
    % RDMs{iROI,iToPlot,3} Euclidian by hand
    % RDMs{iROI,iToPlot,4} Spearman by hand
    % RDMs_CV{iROI,iToPlot,1} RSA toolbox Euclidian/Mahalanobis - All CV
    % RDMs_CV{iROI,iToPlot,2} RSA toolbox Euclidian/Mahalanobis - Day CV
    % RDMs_CV{iROI,iToPlot,3} by hand Euclidian - All CV
    % RDMs_CV{iROI,iToPlot,4} by hand Spearman - All CV
    % RDMs_CV{iROI,iToPlot,5} by hand Euclidian - Day CV
    % RDMs_CV{iROI,iToPlot,6} by hand Spearman - Day CV

    % Reg{iROI,iToPlot,1} Regression
    % Reg{iROI,iToPlot,2} Correlation

    % Reg_cv{iROI,iToPlot,1} Regression  - All CV
    % Reg_cv{iROI,iToPlot,2} Correlation - All CV

    % Reg_day_cv{iROI,iToPlot,1} Regression - Day CV
    % Reg_day_cv{iROI,iToPlot,2} Correlation - Day CV

    %% Get the data
    % RDMs_CV{iROI,iToPlot,Target+1,1} Mahalanobis CV all
    % RDMs_CV{iROI,iToPlot,Target+1,1} Mahalanobis daily CV

    for iSubj = 1:NbSub

        Sub_dir = fullfile(StartDir, SubLs(iSubj).name);
        Save_dir = fullfile(Sub_dir, 'results', 'profiles', 'vol', 'RSA');

        if Do_hs_Idpdtly
            load(fullfile(Save_dir, ['RSA_results_hs_idpdt_' Save_suffix '.mat']),  ...
                 'RDMs', 'RDMs_CV', 'BetaReg_CV', 'BetaReg');
            ihs = 1;
        else
            load(fullfile(Save_dir, ['RSA_results_2_' Save_suffix '.mat']),  ...
                 'RDMs', 'RDMs_CV', 'BetaReg_CV', 'BetaReg');
            ihs = 1;
        end

        for i = 1
            switch i
                case 1
                    %                 RDMs_CV;
                    %                 RDMs
                    %                 BetaReg_CV
                    %                 BetaReg
                case 2
                    %                 Data = RDMs_CV_side;
                case 3
                    %                 Data = RDMs_CV_sens;
            end

            for target = 1:DoTarget

                for iROI = 1:numel(ROIs)

                    for iToPlot = 1:numel(ToPlot)

                        for RDM_to_plot = 1:2
                            Grp_Reg{i, target}{iROI, iToPlot, RDM_to_plot}(:, :, iSubj) = ...
                                BetaReg{iROI, iToPlot, target, RDM_to_plot, ihs}; %#ok<*USENS,*NASGU>
                        end
                        for RDM_to_plot = 1:4
                            Grp_Reg{i, target}{iROI, iToPlot, 2 + RDM_to_plot}(:, :, iSubj) = ...
                                BetaReg_CV{iROI, iToPlot, target, RDM_to_plot, ihs};
                        end

                        for RDM_to_plot = 1:2
                            Grp_RDMs{i, target}{iROI, iToPlot, RDM_to_plot}(:, :, iSubj) = ...
                                RDMs{iROI, iToPlot, target, RDM_to_plot, ihs};
                        end
                        for RDM_to_plot = 1:6
                            Grp_RDMs{i, target}{iROI, iToPlot, 2 + RDM_to_plot}(:, :, iSubj) = ...
                                RDMs_CV{iROI, iToPlot, target, RDM_to_plot, ihs};
                        end

                    end

                end
            end
        end
    end

    for target = 0:(DoTarget - 1)

        for i = 1

            switch i
                case 1
                    if target
                        CondNames = { ...
                                     'Targ A contra', 'Targ A ipsi', ...
                                     'Targ V contra', 'Targ V ipsi', ...
                                     'Targ T contra', 'Targ T ipsi' ...
                                    };
                        FigName = 'Targets VS Targets';
                    elseif Trim_beta
                        CondNames = { ...
                                     'Stim A contra', 'Stim A ipsi', ...
                                     'Stim V contra', 'Stim V ipsi', ...
                                     'Stim T contra', 'Stim T ipsi'...
                                     'Targ A contra', 'Targ A ipsi', ...
                                     'Targ V contra', 'Targ V ipsi', ...
                                     'Targ T contra', 'Targ T ipsi' ...
                                    }; %#ok<*UNRCH>
                        FigName = 'Stim and Targets';
                    else
                        CondNames = { ...
                                     'A contra', 'A ipsi', ...
                                     'V contra', 'V ipsi', ...
                                     'T contra', 'T ipsi' ...
                                    }; %#ok<*UNRCH>
                        FigName = 'Stim VS Stim';
                    end
                    Dest_dir = fullfile(RSA_dir, 'Cdt');

                case 2
                    if target
                        CondNames = {'(Contra-Ipsi)_{Targ_A} ', '(Contra-Ipsi)_{Targ_V}', '(Contra-Ipsi)_{Targ_T}'};
                        FigName = 'Targets - Side VS Side';
                    else
                        CondNames = {'(Contra-Ipsi)_A ', '(Contra-Ipsi)_V', '(Contra-Ipsi)_T'};
                        FigName = 'Side VS Side';
                    end
                    Dest_dir = fullfile(RSA_dir, 'Side');

                case 3
                    if target
                        CondNames = { ...
                                     'Targets - (A-V)_{Contra}', 'Targets - (A-T)_{Contra}', 'Targets - (V-T)_{Contra}', ...
                                     'Targets - (A-V)_{Ipsi}', 'Targets - (A-T)_{Ipsi}', 'Targets - (V-T)_{Ipsi}'};
                        FigName = 'Targets - Sens VS Sens';
                    else
                        CondNames = { ...
                                     '(A-V)_{Contra}', '(A-T)_{Contra}', '(V-T)_{Contra}', ...
                                     '(A-V)_{Ipsi}', '(A-T)_{Ipsi}', '(V-T)_{Ipsi}'};
                        FigName = 'Sens VS Sens';
                    end

                    Dest_dir = fullfile(RSA_dir, 'Sens');

            end

            %% Plot RSAs
            Data_2_plot = Grp_RDMs{i, target + 1};

            for RDM_to_plot = 1:size(Data_2_plot, 3)

                for iToPlot = 1:numel(ToPlot)

                    close all;

                    %% Plot group average
                    clear RDM;

                    for iROI = 1:numel(ROIs)
                        Data = Data_2_plot{iROI, iToPlot, RDM_to_plot};
                        RDM(:, :, iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                    end
                    clear Data;

                    switch RDM_to_plot
                        case 1
                            DataName = 'Euclidian distance';
                        case 2
                            DataName = 'Spearman distance';
                        case 3
                            if Whitened_beta
                                DataName = 'RSA toolbox Mahalanobis - All CV';
                            else
                                DataName = 'RSA toolbox Euclidian - All CV';
                            end
                        case 4
                            if Whitened_beta
                                DataName = 'RSA toolbox Mahalanobis - Day CV';
                            else
                                DataName = 'RSA toolbox Euclidian - Day CV';
                            end
                        case 5
                            DataName = 'Euclidian - All CV handmade';
                        case 6
                            DataName = 'Spearman - All CV handmade';
                        case 7
                            DataName = 'Euclidian - Day CV handmade';
                        case 8
                            DataName = 'Spearman - Day CV handmade';
                    end

                    % Plot
                    figure('name', [FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, ...
                           'Color', [1 1 1], 'visible', 'on');
                    %                 set_tight_figure()

                    rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);

                    rename_subplot([3 3], CondNames, ROIs);

                    Name = sprintf('%s - %s - %s - %s - %s8%s - %s', hs_sufix, DataName, FigName, Save_suffix, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);

                    title_print(Name, Dest_dir);

                    %% Plot subjects
                    clear RDM;

                    for iROI = 1:numel(ROIs)

                        if ranktrans
                            for iSubj = 1:NbSub
                                RDM(:, :, iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(Data_2_plot{iROI, iToPlot, RDM_to_plot}(:, :, iSubj), 1));
                            end
                        else
                            RDM = Data_2_plot{iROI, iToPlot, RDM_to_plot};
                        end

                        IsAllZero = ~squeeze(all(all(RDM == 0, 1), 2));
                        RDM = RDM(:, :, IsAllZero);

                        % Plot
                        figure('name', ['Sujbects - ' FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1]);
                        %                     set_tight_figure()

                        rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);

                        rename_subplot([4 3], CondNames, {SubLs.name}');

                        Name = sprintf('Subjects - %s - %s - %s - %s - %s - %s8%s - %s', hs_sufix, ROIs{iROI}, DataName, FigName, Save_suffix, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);

                        title_print(Name, fullfile(Dest_dir, 'Subjects'));
                    end
                end
            end

            %%  Plot correlation and regression
            Data_2_plot = Grp_Reg{i, target + 1};

            switch i
                case 1
                    SubFolder = 'Cdt';
                case 2
                    SubFolder = 'Side';
                case 3
                    SubFolder = 'Sens';
            end

            for RDM_to_plot = 1:size(Data_2_plot, 3)

                for iToPlot = 1:numel(ToPlot)

                    close all;

                    %% Plot group average
                    clear RDM;

                    for iROI = 1:numel(ROIs)
                        Data = Data_2_plot{iROI, iToPlot, RDM_to_plot};
                        RDM(:, :, iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                    end

                    if ~mod(RDM_to_plot, 2) == 0
                        Dest_dir = fullfile(Reg_dir, SubFolder);
                    else
                        Dest_dir = fullfile(Cor_dir, SubFolder);
                    end

                    switch RDM_to_plot
                        case 1
                            DataName = 'Regression';
                        case 2
                            DataName = 'Correlation';
                        case 3
                            DataName = 'Regression - All CV';
                        case 4
                            DataName = 'Correlation - All CV';
                        case 5
                            DataName = 'Regression - Day CV';
                        case 6
                            DataName = 'Correlation - Day CV';
                    end

                    % Plot
                    figure('name', [FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1]);
                    %                 set_tight_figure()

                    CLIM = [min(RDM(:)) max(RDM(:))];

                    rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                    %                 for iROI=1:numel(ROIs)
                    %                     subplot(3,3,iROI)
                    %                     colormap(ColorMap);
                    %                     imagesc(RDM(:,:,iROI),CLIM)
                    %                     axis square
                    %                 end

                    rename_subplot([3 3], CondNames, ROIs);

                    %                 subplot(3,3,iROI+1)
                    %
                    %                 colormap(ColorMap);
                    %                 imagesc(repmat(linspace(CLIM(2),CLIM(1),400)', [1,200]), CLIM)
                    %                 axis square
                    %                 set(gca,'tickdir', 'out', 'xtick', [],'xticklabel',  [], ...
                    %                     'ytick', linspace(1,400,5),...
                    %                     'yticklabel', linspace(CLIM(2),CLIM(1),5), ...
                    %                     'ticklength', [0.01 0.01], 'fontsize', 8, 'YAxisLocation','right')
                    %                 box off

                    Name = sprintf('%s - %s - %s - %s - %s8%s - %s', hs_sufix, DataName, FigName, Save_suffix, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);

                    title_print(Name, Dest_dir);

                    %% Plot subjects
                    clear RDM;

                    for iROI = 1:numel(ROIs)

                        if ranktrans
                            for iSubj = 1:NbSub
                                RDM(:, :, iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(Data_2_plot{iROI, iToPlot, RDM_to_plot}(:, :, iSubj), 1));
                            end
                        else
                            RDM = Data_2_plot{iROI, iToPlot, RDM_to_plot};
                        end

                        CLIM = [min(RDM(:)) max(RDM(:))];

                        % Plot
                        figure('name', ['Sujbects - ' FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1]);
                        %                     set_tight_figure()

                        rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                        %                     for iSubj=1:NbSub
                        %                         subplot(4,3,iSubj)
                        %                         colormap(ColorMap);
                        %                         imagesc(RDM(:,:,iSubj),CLIM)
                        %                         axis square
                        %                     end

                        rename_subplot([4 3], CondNames, {SubLs.name}');

                        %                     subplot(4,3,iSubj+1)
                        %
                        %                     colormap(ColorMap);
                        %                     imagesc(repmat(linspace(CLIM(2),CLIM(1),400)', [1,200]), CLIM)
                        %                     axis square
                        %                     set(gca,'tickdir', 'out', 'xtick', [],'xticklabel',  [], ...
                        %                         'ytick', linspace(1,400,5),...
                        %                         'yticklabel', linspace(CLIM(2),CLIM(1),5), ...
                        %                         'ticklength', [0.01 0.01], 'fontsize', 8, 'YAxisLocation','right')
                        %                     box off

                        Name = sprintf('Subjects - %s - %s - %s - %s - %s - %s8%s - %s', hs_sufix, ROIs{iROI}, DataName, FigName, Save_suffix, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);

                        title_print(Name, fullfile(Dest_dir, 'Subjects'));
                    end

                end

            end

        end
    end

end

function RDM = Extract_rankTransform_RDM(Data, NbSub, ranktrans)

    if ranktrans
        for iSubj = 1:NbSub
            tmp(:, :, iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(Data(:, :, iSubj), 1));
        end
    else
        tmp = Data;
    end
    IsAllZero = ~squeeze(all(all(tmp == 0, 1), 2));
    RDM = nanmean(tmp(:, :, IsAllZero), 3);

end

function title_print(Name, Dest_dir)
    mtit(sprintf(strrep([Name ' - 2'], '8', '\n')), 'fontsize', 10, 'xoff', 0, 'yoff', .025);
    Name = strrep(Name, '8', ' - ');
    % saveFigure(fullfile(Dest_dir, strrep([Name '.pdf'], ' ', '_')));
    print(fullfile(Dest_dir, strrep([Name '.tiff'], ' ', '_')), '-dtiff');
    % print(fullfile(Dest_dir, strrep([Name '.pdf'], ' ', '_')), '-dpdf')
end
