% (C) Copyright 2020 Remi Gau
function MVPA_surf_grp_avg

    % TODO
    % - fix because this is broken: need to run MVPA in surf to generate input
    % for this

    clc;
    clear;

    [Dirs] = set_dir('surf');
    [SubLs, NbSub] = get_subject_list(Dirs.MVPA_resultsDir);

    ParamToPlot = {'Cst', 'Lin', 'Avg', 'ROI'};

    NbLayers = 6;

    % ROI
    ROIs(1) = struct('name', 'V1');
    ROIs(end + 1) = struct('name', 'V2');
    ROIs(end + 1) = struct('name', 'A1');
    ROIs(end + 1) = struct('name', 'PT');

    % from one to 8 ; can be a vector ; see ChooseNorm()
    norm_to_use = 6; % 6

    % Options for the SVM
    [opt, ~] = get_mvpa_options();
    opt.toplot = ParamToPlot{1};
    disp(opt);

    SVM_Ori = get_mvpa_classification(ROIs);
    SVM_Ori(10:end) = [];
    disp(SVM_Ori);

    DesMat = set_design_mat_lam_GLM(NbLayers);

    for Norm = norm_to_use

        clear SVM;

        [opt] = ChooseNorm(Norm, opt);

        SaveSufix = CreateSaveSuffix(opt, [], NbLayers, 'surf');

        SVM = SVM_Ori;

        for i = 1:numel(SVM)
            SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI_2_analyse).name}); %#ok<*AGROW>
        end

        %% Gets data for each subject
        for iSubj = 1:NbSub
            fprintf('\n\nProcessing %s', SubLs(iSubj).name);

            SubDir = fullfile(Dirs.MVPA_resultsDir, SubLs(iSubj).name);

            for iSVM = 1:numel(SVM)
                fprintf('\n Running SVM:  %s', SVM(iSVM).name);

                for iROI = 1:numel(ROIs)

                    File2Load = fullfile( ...
                                         SubDir, ...
                                         strcat( ...
                                                'SVM-', SVM(iSVM).name, ...
                                                '_no-pool-ROI-', SVM(iSVM).ROI(iROI).name, ...
                                                SaveSufix));

                    SVM(iSVM).ROI(iROI).grp = nan(1, NbLayers, 2);
                    SVM(iSVM).ROI(iROI).DATA{iSubj} = [];
                    SVM(iSVM).ROI(iROI).layers.DATA{iSubj} = [];

                    if ~exist(File2Load, 'file')

                        error('\nThe file %s was not found.', File2Load);

                    else

                        load(File2Load, 'Results', 'Class_Acc', 'opt');

                        for ihs = 1:2

                            SVM(iSVM).ROI(iROI).grp(iSubj, ihs) = Class_Acc.TotAcc(ihs);
                            if isempty(Class_Acc.TotAccLayers{ihs})
                                SVM(iSVM).ROI(iROI).layers.grp(:, :, iSubj, ihs) = nan(NbLayers);
                            else
                                SVM(iSVM).ROI(iROI).layers.grp(:, :, iSubj, ihs) = Class_Acc.TotAccLayers{ihs};
                            end

                            % Extract results
                            CV = Results(ihs).session(end).rand.perm.CV;
                            NbCV = size(CV, 1); %#ok<*NODEF>

                            for iCV = 1:NbCV

                                % For the whole ROI
                                SVM(iSVM).ROI(iROI).DATA{iSubj}(iCV, ihs) = CV(iCV).acc;

                                if isempty(CV(iCV).layers.results{1})
                                    SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(:, iCV, ihs) = nan(1, NbLayers);
                                else
                                    for iLayer = 1:NbLayers
                                        label = CV(iCV).layers.results{1}{iLayer}.label;
                                        pred = CV(iCV).layers.results{1}{iLayer}.pred(:, iLayer);

                                        SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(iLayer, iCV, ihs) = mean(pred == label);
                                        clear pred label;
                                    end
                                end

                            end
                        end
                    end

                    clear Results Class_Acc;

                end

            end
        end

        %% Averages over subjects
        for iSVM = 1:numel(SVM)
            for iROI = 1:numel(ROIs)

                SVM(iSVM).ROI(iROI).MEAN = nanmean(SVM(iSVM).ROI(iROI).grp);
                SVM(iSVM).ROI(iROI).STD = nanstd(SVM(iSVM).ROI(iROI).grp);
                SVM(iSVM).ROI(iROI).SEM = nansem(SVM(iSVM).ROI(iROI).grp);

                for ihs = 1:2
                    for iSubj = 1:numel(SVM(iSVM).ROI(iROI).layers.DATA)
                        tmp(iSubj, 1:NbLayers) = mean(SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(:, :, ihs), 2);
                    end
                    SVM(iSVM).ROI(iROI).layers.MEAN(ihs, :) = mean(tmp);
                    SVM(iSVM).ROI(iROI).layers.STD(ihs, :) = std(tmp);
                    SVM(iSVM).ROI(iROI).layers.SEM(ihs, :) = nansem(tmp);
                end

            end
        end

        %% Betas from profile fits
        fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS');

        for iSVM = 1:numel(SVM)
            fprintf('\n Running SVM:  %s', SVM(iSVM).name);

            for iROI = 1:numel(ROIs)

                %% Actually compute betas
                for iSub = 1:NbSub

                    for ihs = 1:2

                        Blocks = SVM(iSVM).ROI(iROI).layers.DATA{iSub}(:, :, ihs);

                        if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

                            Y = Blocks - .5;
                            [B] = laminar_glm(DesMat, Y);

                            SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, iSub, ihs) = B;

                            clear Y B;

                        else
                            SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, iSub) = nan(size(DesMat, 2), 1);

                        end

                    end

                end

                %% Group stat on betas
                for ihs = 1:2
                    tmp = SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, :, ihs);
                    SVM(iSVM).ROI(iROI).layers.Beta.MEAN(:, ihs) = nanmean(tmp, 2);
                    SVM(iSVM).ROI(iROI).layers.Beta.Beta.STD(:, ihs) = nanstd(tmp, 2);
                    SVM(iSVM).ROI(iROI).layers.Beta.Beta.SEM(:, ihs) = nansem(tmp, 2);

                    % T-Test
                    [~, P] = ttest(tmp');
                    SVM(iSVM).ROI(iROI).Beta.P(ihs, :) = P;

                    clear tmp P;
                end

            end
        end

        %% Saves
        fprintf('\n\nSaving\n');

        for iSVM = 1:numel(SVM)
            for iROI = 1:numel(ROIs)
                Results = SVM(iSVM).ROI(iROI);
                save(fullfile(ResultsDir, strcat('Grp_', SVM(iSVM).ROI(iROI).name, '_', strrep(SVM(iSVM).name, ' ', '-'), ...
                                                 '_NoPoolQuadGLM',  SaveSufix)), 'Results');
            end
        end

        save(fullfile(ResultsDir, strcat('GrpNoPoolQuadGLM', SaveSufix)));

        cd(StartDir);

    end

end
