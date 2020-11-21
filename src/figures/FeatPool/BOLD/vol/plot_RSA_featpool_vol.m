function plot_RSA_featpool_vol

    close all;
    clear;
    clc;

    StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
    Get_dependencies('/home/rxg243/Dropbox/');

    cd (StartDir);
    SubLs = dir('sub*');
    NbSub = numel(SubLs);

    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

    ROIs = { ...
            'A1', ...
            'PT', ...
            'V1', ...
            'V2', ...
            'V3', ...
            'V4', ...
            'V5'
           };

    RSA_dir = fullfile(StartDir, 'figures', 'RSA');
    mkdir(RSA_dir, 'Cdt');
    mkdir(fullfile(RSA_dir, 'Cdt', 'Subjects'));

    ColorMap = brain_colour_maps('hot_increasing');

    FigDim = [100, 100, 1000, 1500];

    for beta_type = 0:1

        switch beta_type
            case 0
                whitened_beta = 0;
                Save_suffix = 'beta-raw';
            case 1
                whitened_beta = 1;
                Save_suffix = 'beta-wht';
        end

        %% Get the data
        % RDMs_CV{iROI,iToPlot,Target+1,1} Mahalanobis CV all
        % RDMs_CV{iROI,iToPlot,Target+1,1} Mahalanobis daily CV

        for iSubj = 1:NbSub

            Subj_ID = SubLs(iSubj).name;
            Subj_dir = fullfile(StartDir, SubLs(iSubj).name);
            Save_dir = fullfile(Subj_dir, 'results', 'rsa', 'vol');

            if whitened_beta
                Results_file_name = fullfile(Save_dir, [Subj_ID '_results_RSA_whitened_betas.mat']);
            else
                Results_file_name = fullfile(Save_dir, [Subj_ID '_results_RSA_raw_betas.mat']);
            end

            load(Results_file_name,  'RDMs');

            for iTarget = 1:2

                for iROI = 1:numel(ROIs)

                    for iHS = 1:2

                        Grp_RDMs{iROI, iHS, iTarget}(:, :, iSubj) = RDMs{iROI, iHS, iTarget}; %#ok<*SAGROW>
                    end

                end
            end
        end

        %% plot
        Dest_dir = fullfile(RSA_dir, 'Cdt');

        if whitened_beta
            DataName = 'RSA toolbox Mahalanobis - All CV';
        else
            DataName = 'RSA toolbox Euclidian - All CV';
        end

        for ranktrans = 0:1

            if ranktrans
                ranktrans_suffix = 'ranktrans-1';
            else
                ranktrans_suffix = 'ranktrans-0';
            end

            for isplotranktrans = 0:1

                if isplotranktrans
                    plotranktrans_suffix = 'plotranktrans-1';
                else
                    plotranktrans_suffix = 'plotranktrans-0';
                end

                for iTarget = 0:1

                    if iTarget
                        CondNames = { ...
                                     'Targ A L', 'Targ A R', ...
                                     'Targ V L', 'Targ V R', ...
                                     'Targ T L', 'Targ T R' ...
                                    };
                        FigName = 'Targets VS Targets';
                    else

                        CondNames = { ...
                                     'A Left', 'A Right', ...
                                     'V Left', 'V Right', ...
                                     'T Left', 'T Right' ...
                                    }; %#ok<*UNRCH>
                        FigName = 'Stim VS Stim';
                    end

                    for iHS = 1:2
                        close all;
                        clear RDM;

                        if iHS == 1
                            hs_sufix = 'LHS';
                        else
                            hs_sufix = 'RHS';
                        end

                        %% Plot group average
                        %                     ROIs = {...
                        %                         'A1',...
                        %                         'PT',...
                        %                         'V1',...
                        %                         'V2',...
                        %                         'V3',...
                        %                         'V4',...
                        %                         'V5'
                        %                         };
                        %                     for iROI=1:numel(ROIs)
                        %                         Data = Grp_RDMs{iROI,iHS,iTarget+1};
                        %                         RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        %                     end
                        %                     tmp = RDM;
                        %                     RDM(:,:,1:2) = tmp(:,:,end-1:end);
                        %                     RDM(:,:,3:end) = tmp(:,:,1:end-2);
                        %                     clear tmp
                        %
                        %                     % Plot
                        %                     figure('name', [FigName ' - ' DataName], 'Position', FigDim, ...
                        %                         'Color', [1 1 1], 'visible', 'on')
                        %
                        %                     rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                        %
                        %                     rename_subplot([3 3],CondNames,ROIs)
                        %
                        %                     Name = sprintf('NEW - %s - %s - %s - %s8%s - %s', DataName, FigName, Save_suffix, hs_sufix,...
                        %                         ranktrans_suffix, plotranktrans_suffix);
                        %
                        %                     title_print(Name,Dest_dir)
                        %

                        %% Plot subjects
                        clear RDM;
                        ROIs = { ...
                                'V1', ...
                                'V2', ...
                                'V3', ...
                                'V4', ...
                                'V5', ...
                                'A1', ...
                                'PT' ...
                               };

                        for iROI = 1:numel(ROIs)

                            if ranktrans
                                for iSubj = 1:NbSub
                                    RDM(:, :, iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(Grp_RDMs{iROI, iHS, iTarget + 1}(:, :, iSubj), 1));
                                end
                            else
                                RDM = Grp_RDMs{iROI, iHS, iTarget + 1};
                            end

                            IsAllZero = ~squeeze(all(all(RDM == 0, 1), 2));
                            RDM = RDM(:, :, IsAllZero);

                            % Plot
                            figure('name', ['Sujbects - ' FigName ' - ' DataName], 'Position', FigDim, 'Color', [1 1 1]);
                            %                     set_tight_figure()

                            rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);

                            rename_subplot([4 3], CondNames, {SubLs.name}');

                            Name = sprintf('NEW - Subjects - %s - %s - %s - %s - %s8%s - %s', DataName, ROIs{iROI}, FigName, Save_suffix, hs_sufix, ...
                                           ranktrans_suffix, plotranktrans_suffix);

                            title_print(Name, fullfile(Dest_dir, 'Subjects'));
                        end
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
    mtit(sprintf(strrep(Name, '8', '\n')), 'fontsize', 10, 'xoff', 0, 'yoff', .025);
    Name = strrep(Name, '8', ' - ');
    % saveFigure(fullfile(Dest_dir, strrep([Name '.pdf'], ' ', '_')));
    print(fullfile(Dest_dir, strrep([Name '.tiff'], ' ', '_')), '-dtiff');
    % print(fullfile(Dest_dir, strrep([Name '.pdf'], ' ', '_')), '-dpdf')
end
