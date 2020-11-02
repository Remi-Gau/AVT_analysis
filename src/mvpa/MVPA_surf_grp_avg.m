function MVPA_surf_grp_avg

    clc;
    clear;

    if isunix
        CodeDir = '/home/remi/github/AVT_analysis';
        StartDir = '/home/remi';
    elseif ispc
        CodeDir = 'D:\github\AVT-7T-code';
        StartDir = 'D:\';
    else
        disp('Platform not supported');
    end

    addpath(genpath(fullfile(CodeDir, 'subfun')));

    [Dirs] = set_dir();

    Get_dependencies();

    SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
    NbSub = numel(SubLs);

    NbLayers = 6;

    ROIs_ori = {
                'A1', ...
                'PT', ...
                'V1', ...
                'V2'};

    ToPlot = {'Cst', 'Lin', 'Avg', 'ROI'};

    % Options for the SVM
    [opt, ~] = get_mvpa_options();

    SVM_Ori = get_mvpa_classification(ROIs_ori);
    SVM_Ori(10:end) = [];

    DesMat = set_design_mat_lam_GLM(NbLayers);

    for iToPlot = 1

        opt.toplot = ToPlot{iToPlot};

        if iToPlot == 4
            Do_layers = 1;
        else
            Do_layers = 0;
        end

        for Norm = 6

            clear ROIs SVM;

            [opt] = ChooseNorm(Norm, opt);

            SaveSufix = CreateSaveSuffix(opt, [], NbLayers, 'surf');

            SVM = SVM_Ori;

            for i = 1:numel(SVM)
                for j = 1:numel(SVM(i).ROI_2_analyse)
                    SVM(i).ROI(j).name = ROIs_ori{SVM(i).ROI_2_analyse(j)}; %#ok<*AGROW>
                end
            end

            %% Gets data for each subject
            for iSubj = 1:NbSub
                fprintf('\n\nProcessing %s', SubLs(iSubj).name);

                SubDir = fullfile(Dirs.DerDir, SubLs(iSubj).name);
                SaveDir = fullfile(SubDir, 'results', 'SVM');

                for iSVM = 1:numel(SVM)
                    fprintf('\n Running SVM:  %s', SVM(iSVM).name);

                    for iROI = 1:numel(SVM(i).ROI_2_analyse)

                        File2Load = fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]);

                        if exist(File2Load, 'file')

                            load(File2Load, 'Results', 'Class_Acc', 'opt');

                            SVM(iSVM).ROI(iROI).grp(iSubj) = Class_Acc.TotAcc;
                            %                     if Do_layers
                            %                         SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = Class_Acc.TotAccLayers{1};
                            %                     end

                            % Extract results
                            CV = Results.session(end).rand.perm.CV;
                            NbCV = size(CV, 1); %#ok<*NODEF>

                            for iCV = 1:NbCV

                                % For the whole ROI
                                SVM(iSVM).ROI(iROI).DATA{iSubj}(iCV) = CV(iCV).acc;

                                if Do_layers
                                    for iLayer = 1:NbLayers
                                        label = CV(iCV).layers.results{1}{iLayer}.label;
                                        pred = CV(iCV).layers.results{1}{iLayer}.pred(:, iLayer);

                                        SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(iLayer, iCV) = mean(pred == label);
                                        clear pred label;
                                    end
                                end

                            end

                        else
                            warning('\nThe file %s was not found.', File2Load);

                            SVM(iSVM).ROI(iROI).DATA{iSubj} = [];
                            SVM(iSVM).ROI(iROI).grp(iSubj) = NaN;
                            if Do_layers
                                SVM(iSVM).ROI(iROI).layers.DATA{iSubj} = [];
                                %                         SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = nan(NbLayers);
                            end

                        end
                        clear Results Class_Acc;

                    end
                end
            end

            %% Averages over subjects
            for iSVM = 1:numel(SVM)
                for iROI = 1:numel(ROIs_ori)

                    SVM(iSVM).ROI(iROI).MEAN = nanmean(SVM(iSVM).ROI(iROI).grp);
                    SVM(iSVM).ROI(iROI).STD = nanstd(SVM(iSVM).ROI(iROI).grp);
                    SVM(iSVM).ROI(iROI).SEM = nansem(SVM(iSVM).ROI(iROI).grp);

                    if Do_layers
                        for iSubj = 1:numel(SVM(iSVM).ROI(iROI).layers.DATA)
                            tmp(iSubj, 1:NbLayers) = mean(SVM(iSVM).ROI(iROI).layers.DATA{iSubj}, 2);
                        end
                        SVM(iSVM).ROI(iROI).layers.MEAN = mean(tmp);
                        SVM(iSVM).ROI(iROI).layers.STD = std(tmp);
                        SVM(iSVM).ROI(iROI).layers.SEM = nansem(tmp);
                    end

                end
            end

            %% Betas from profile fits
            if Do_layers
                fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS');

                for iSVM = 1:numel(SVM)
                    fprintf('\n Running SVM:  %s', SVM(iSVM).name);

                    for iROI = 1:numel(ROIs_ori)

                        %% Actually compute betas
                        for iSub = 1:NbSub

                            Blocks = SVM(iSVM).ROI(iROI).layers.DATA{iSub};

                            if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

                                Y = Blocks - .5;
                                [B] = laminar_glm(DesMat, Y);

                                SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, iSub) = B;

                                clear Y B;

                            else
                                SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, iSub) = nan(size(DesMat, 2), 1);

                            end

                        end

                        %% Group stat on betas
                        tmp = SVM(iSVM).ROI(iROI).layers.Beta.DATA;
                        SVM(iSVM).ROI(iROI).layers.Beta.MEAN = nanmean(tmp, 2);
                        SVM(iSVM).ROI(iROI).layers.Beta.Beta.STD = nanstd(tmp, 2);
                        SVM(iSVM).ROI(iROI).layers.Beta.Beta.SEM = nansem(tmp, 2);

                        % T-Test
                        [~, P] = ttest(tmp');
                        SVM(iSVM).ROI(iROI).Beta.P = P;

                        clear tmp P;

                    end
                end

            end

            %% Saves
            fprintf('\n\nSaving\n');

            for iSVM = 1:numel(SVM)
                for iROI = 1:numel(ROIs_ori)
                    Results = SVM(iSVM).ROI(iROI);
                    save(fullfile(Dirs.MVPA_resultsDir, strcat('Grp_', SVM(iSVM).ROI(iROI).name, '_', strrep(SVM(iSVM).name, ' ', '-'), ...
                                                               '_PoolQuadGLM',  SaveSufix, '.mat')), 'Results');
                end
            end

            save(fullfile(Dirs.MVPA_resultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')));

            cd(StartDir);

        end
    end

end
