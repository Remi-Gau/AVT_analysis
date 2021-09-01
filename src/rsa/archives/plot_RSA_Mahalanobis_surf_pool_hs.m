% (C) Copyright 2020 Remi Gau
function plot_RSA_Mahalanobis_surf_pool_hs(StartDir, SubLs, ToPlot, ranktrans, isplotranktrans)

    if nargin < 4 || isempty(ranktrans)
        ranktrans = 0;
    end

    if nargin < 5 || isempty(isplotranktrans)
        isplotranktrans = 0;
    end

    NbSub = numel(SubLs);

    load(fullfile(StartDir, 'sub-02', 'roi', 'surf', 'sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex');
    % to know how many ROIs we have

    ColorMap = brain_colour_maps('hot_increasing');

    FigDim = [100, 100, 1000, 1500];

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

    RSA_dir = fullfile(StartDir, 'figures', 'RSA');

    %% Get the data
    % RDMs_CV{iROI,iToPlot,Target+1,1} Mahalanobis CV all
    % RDMs_CV{iROI,iToPlot,Target+1,1} Mahalanobis daily CV

    for iSubj = 1:NbSub

        Sub_dir = fullfile(StartDir, SubLs(iSubj).name);

        load(fullfile(Sub_dir, 'results', 'profiles', 'surf', ...
                      'RSA', 'RSA_mahalanobis_results_2.mat'),  ...
             'RDMs_CV', 'RDMs_CV_sens', 'RDMs_CV_side');

        for i = 1:3
            switch i
                case 1
                    Data = RDMs_CV;
                case 2
                    Data = RDMs_CV_side;
                case 3
                    Data = RDMs_CV_sens;
            end

            for target = 0:1

                for iROI = 1:numel(ROI)

                    for iToPlot = 1:numel(ToPlot)
                        for RDM_to_plot = 1:2

                            Grp_RDMs{i, target + 1}{iROI, iToPlot, RDM_to_plot}(:, :, iSubj) = ...
                                Data{iROI, iToPlot, target + 1, RDM_to_plot};
                        end
                    end

                end
            end
        end
    end

    %% Plot
    for target = 0:1

        for i = 1:3

            Data_2_plot = Grp_RDMs{i, target + 1};

            switch i
                case 1
                    if target
                        CondNames = { ...
                                     'Targ A contra', 'Targ A ipsi', ...
                                     'Targ V contra', 'Targ V ipsi', ...
                                     'Targ T contra', 'Targ T ipsi' ...
                                    };
                        FigName = 'Targets VS Targets';
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
                        CondNames = {'(Contra-Ipsi)_{Targ_A} ', ...
                                     '(Contra-Ipsi)_{Targ_V}', ...
                                     '(Contra-Ipsi)_{Targ_T}'};
                        FigName = 'Targets - Side VS Side';
                    else
                        CondNames = {'(Contra-Ipsi)_A ', ...
                                     '(Contra-Ipsi)_V', ...
                                     '(Contra-Ipsi)_T'};
                        FigName = 'Side VS Side';
                    end
                    Dest_dir = fullfile(RSA_dir, 'Side');

                case 3
                    if target
                        CondNames = { ...
                                     'Targets - (A-V)_{Contra}', ...
                                     'Targets - (A-T)_{Contra}', ...
                                     'Targets - (V-T)_{Contra}', ...
                                     'Targets - (A-V)_{Ipsi}', ...
                                     'Targets - (A-T)_{Ipsi}', ...
                                     'Targets - (V-T)_{Ipsi}'};
                        FigName = 'Targets - Sens VS Sens';
                    else
                        CondNames = { ...
                                     '(A-V)_{Contra}', ...
                                     '(A-T)_{Contra}', ...
                                     '(V-T)_{Contra}', ...
                                     '(A-V)_{Ipsi}', ...
                                     '(A-T)_{Ipsi}', ...
                                     '(V-T)_{Ipsi}'};
                        FigName = 'Sens VS Sens';
                    end

                    Dest_dir = fullfile(RSA_dir, 'Sens');

            end

            for RDM_to_plot = 1:2

                for iToPlot = 1:numel(ToPlot)

                    close all;

                    %% Plot group average
                    clear RDM;

                    switch RDM_to_plot

                        case 1
                            for iROI = 1:numel(ROI)
                                Data = Data_2_plot{iROI, iToPlot, 1};
                                RDM(:, :, iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                            end
                            DataName = 'RSA toolbox Mahalanobis - All CV';

                        case 2
                            for iROI = 1:numel(ROI)
                                Data = Data_2_plot{iROI, iToPlot, 2};
                                RDM(:, :, iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                            end
                            DataName = 'RSA toolbox Mahalanobis - Day CV';

                    end

                    clear Data;

                    % Plot
                    figure('name', [FigName ' - ' DataName ' - ' ToPlot{iToPlot}], ...
                           'Position', FigDim, 'Color', [1 1 1]);

                    rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);

                    rename_subplot([3 3], CondNames, {ROI.name}');

                    Name = sprintf('%s - %s - %s8%s - %s', DataName, FigName, ...
                                   ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);

                    title_print(Name, fullfile(Dest_dir));

                    %% Plot subjects
                    clear RDM;

                    for iROI = 1:numel(ROI)
                        switch RDM_to_plot
                            case 1
                                RDM = Data_2_plot{iROI, iToPlot, 1};
                            case 2
                                RDM = Data_2_plot{iROI, iToPlot, 2};
                        end

                        if ranktrans
                            for iSubj = 1:NbSub
                                RDM(:, :, iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM(:, :, iSubj), 1));
                            end
                        end

                        IsAllZero = ~squeeze(all(all(RDM == 0, 1), 2));
                        RDM = RDM(:, :, IsAllZero);
                        %                 CLIM = [min(RDM(:)) max(RDM(:))];

                        % Plot
                        figure('name', ['Sujbects - ' FigName ' - ' DataName ' - ' ...
                                        ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1]);

                        rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);

                        rename_subplot([4 3], CondNames, {SubLs.name}');

                        Name = sprintf('Subjects - %s - %s - %s - %s8%s - %s', ROI(iROI).name, ...
                                       DataName, FigName, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);

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
