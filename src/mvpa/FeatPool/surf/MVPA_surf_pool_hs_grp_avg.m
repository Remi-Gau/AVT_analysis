function MVPA_surf_pool_hs_grp_avg

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

    ResultsDir = fullfile(StartDir, 'results', 'SVM');
    [~, ~, ~] = mkdir(ResultsDir);

    NbLayers = 6;

    % Options for the SVM
    [opt, ~] = get_mvpa_options();

    DesMat = set_design_mat_lam_GLM(NbLayers);

    for Norm = 6

        clear ROIs SVM;

        [opt] = ChooseNorm(Norm, opt);

        SaveSufix = CreateSaveSuffix(opt, [], NbLayers, 'surf');

        % ROI
        ROIs(1) = struct('name', 'V1');
        ROIs(end + 1) = struct('name', 'V2');
        %     ROIs(end+1) = struct('name', 'V3');
        %     ROIs(end+1) = struct('name', 'V4');
        %     ROIs(end+1) = struct('name', 'V5');

        ROIs(end + 1) = struct('name', 'A1');
        ROIs(end + 1) = struct('name', 'PT');

        % Analysis
        SVM(1) = struct('name', 'A Ipsi VS Contra', 'ROI', 1:length(ROIs));
        SVM(end + 1) = struct('name', 'V Ipsi VS Contra', 'ROI', 1:length(ROIs));
        SVM(end + 1) = struct('name', 'T Ipsi VS Contra', 'ROI', 1:length(ROIs));

        SVM(end + 1) = struct('name', 'A VS V Ipsi', 'ROI', 1:length(ROIs));
        SVM(end + 1) = struct('name', 'A VS T Ipsi', 'ROI', 1:length(ROIs));
        SVM(end + 1) = struct('name', 'V VS T Ipsi', 'ROI', 1:length(ROIs));

        SVM(end + 1) = struct('name', 'A VS V Contra', 'ROI', 1:length(ROIs));
        SVM(end + 1) = struct('name', 'A VS T Contra', 'ROI', 1:length(ROIs));
        SVM(end + 1) = struct('name', 'V VS T Contra', 'ROI', 1:length(ROIs));

        for i = 1:numel(SVM)
            SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI).name}); %#ok<*AGROW>
        end

        %% Gets data for each subject
        for iSubj = 1:NbSub
            fprintf('\n\nProcessing %s', SubLs(iSubj).name);

            SubDir = fullfile(Dirs.DerDir, SubLs(iSubj).name);
            SaveDir = fullfile(SubDir, 'results', 'SVM');

            for iSVM = 1:numel(SVM)
                fprintf('\n Running SVM:  %s', SVM(iSVM).name);

                for iROI = 1:numel(ROIs)

                    File2Load = fullfile(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]));

                    if exist(File2Load, 'file')

                        load(File2Load, 'Results', 'Class_Acc', 'opt');

                        %                 File2Save = strrep(File2Load, 'vol','surf');
                        %
                        %                 tmp1 = opt;
                        %                 tmp2 = Class_Acc;
                        %                 Class_Acc = tmp1;
                        %                 opt = tmp2;
                        %                 save(File2Save, 'Results', 'Class_Acc', 'opt')

                        SVM(iSVM).ROI(iROI).grp(iSubj) = Class_Acc.TotAcc;
                        %                     SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = Class_Acc.TotAccLayers{1};

                        % Extract results
                        CV = Results.session(end).rand.perm.CV;
                        NbCV = size(CV, 1); %#ok<*NODEF>

                        for iCV = 1:NbCV

                            % For the whole ROI
                            SVM(iSVM).ROI(iROI).DATA{iSubj}(iCV) = CV(iCV).acc;

                            for iLayer = 1:NbLayers
                                label = CV(iCV).layers.results{1}{iLayer}.label;
                                pred = CV(iCV).layers.results{1}{iLayer}.pred(:, iLayer);

                                SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(iLayer, iCV) = mean(pred == label);
                                clear pred label;
                            end

                        end

                    else
                        warning('\nThe file %s was not found.', File2Load);

                        SVM(iSVM).ROI(iROI).grp(iSubj, 1:NbLayers) = nan(1, NbLayers);
                        SVM(iSVM).ROI(iROI).DATA{iSubj} = [];
                        SVM(iSVM).ROI(iROI).layers.DATA{iSubj} = [];

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

                for iSubj = 1:numel(SVM(iSVM).ROI(iROI).layers.DATA)
                    tmp(iSubj, 1:NbLayers) = mean(SVM(iSVM).ROI(iROI).layers.DATA{iSubj}, 2);
                end
                SVM(iSVM).ROI(iROI).layers.MEAN = mean(tmp);
                SVM(iSVM).ROI(iROI).layers.STD = std(tmp);
                SVM(iSVM).ROI(iROI).layers.SEM = nansem(tmp);

            end
        end

        %% Betas from profile fits
        fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS');

        for iSVM = 1:numel(SVM)
            fprintf('\n Running SVM:  %s', SVM(iSVM).name);

            for iROI = 1:numel(ROIs)

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

        %% Saves
        fprintf('\n\nSaving\n');

        for iSVM = 1:numel(SVM)
            for iROI = 1:numel(ROIs)
                Results = SVM(iSVM).ROI(iROI);
                save(fullfile(ResultsDir, strcat('Grp_', SVM(iSVM).ROI(iROI).name, '_', strrep(SVM(iSVM).name, ' ', '-'), ...
                                                 '_PoolQuadGLM',  SaveSufix, '.mat')), 'Results');
            end
        end

        save(fullfile(ResultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')));

        cd(StartDir);

    end

end
