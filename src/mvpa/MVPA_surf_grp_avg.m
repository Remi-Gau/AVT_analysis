% (C) Copyright 2020 Remi Gau

% takes data from each subjects and computes the group average

clc;
clear;

[Dirs] = set_dir('surf');
[SubLs, NbSub] = get_subject_list(Dirs.MVPA_resultsDir);

NbLayers = 6;

ROIs_ori = {
            'A1', ...
            'PT', ...
            'V1', ...
            'V2'};

% Some data is missing for Avg and ROI
ToPlot = {'Cst', 'Lin', 'Avg', 'ROI'};
to_plot = 1;

% from one to 8 ; can be a vector ; see ChooseNorm()
norm_to_use = 6; % 6

% Options for the SVM
[opt, ~] = get_mvpa_options();
disp(opt);

SVM_Ori = get_mvpa_classification(ROIs_ori);
SVM_Ori(10:end) = [];
disp(SVM_Ori);

DesMat = set_design_mat_lam_GLM(NbLayers);

%%

Do_layers = 0;
if iToPlot == 4
    Do_layers = 1;
end

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

    SubDir = fullfile(Dirs.MVPA_resultsDir, SubLs(iSubj).name);

    for iSVM = 1:numel(SVM)
        fprintf('\n Running SVM:  %s', SVM(iSVM).name);

        for iROI = 1:numel(SVM(i).ROI_2_analyse)

            File2Load = fullfile( ...
                                 SubDir, ...
                                 strcat( ...
                                        'SVM-', SVM(iSVM).name, ...
                                        '_ROI-', SVM(iSVM).ROI(iROI).name, ...
                                        SaveSufix));

            % initialize
            SVM(iSVM).ROI(iROI).DATA{iSubj} = [];
            SVM(iSVM).ROI(iROI).grp(iSubj) = NaN;
            if Do_layers
                SVM(iSVM).ROI(iROI).layers.DATA{iSubj} = [];
                % SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = nan(NbLayers);
            end

            if ~exist(File2Load, 'file')
                error('\nThe file %s was not found.', File2Load);

            else

                fprintf('\n  Loading file: %s', File2Load);

                load(File2Load, 'Results', 'Class_Acc', 'opt');

                SVM(iSVM).ROI(iROI).grp(iSubj) = Class_Acc.TotAcc;
                % if Do_layers
                %   SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = Class_Acc.TotAccLayers{1};
                % end

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
                tmp(iSubj, 1:NbLayers) = ...
                  mean(SVM(iSVM).ROI(iROI).layers.DATA{iSubj}, 2);
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

                SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, iSub) = ...
                  nan(size(DesMat, 2), 1);

                if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

                    Y = Blocks - .5;
                    [B] = laminar_glm(DesMat, Y);

                    SVM(iSVM).ROI(iROI).layers.Beta.DATA(:, iSub) = B;

                    clear Y B;
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
        Filename = fullfile( ...
                            Dirs.MVPA_resultsDir, ...
                            'group', ...
                            strcat( ...
                                   'Grp_', SVM(iSVM).ROI(iROI).name, ...
                                   '_', strrep(SVM(iSVM).name, ' ', '-'), ...
                                   '_PoolQuadGLM',  SaveSufix));
        fprintf('Saving file: %s\n', Filename);
        save(Filename, 'Results');
    end
end

Filename = fullfile( ...
                    Dirs.MVPA_resultsDir, ...
                    'group', ...
                    ['GrpPoolQuadGLM', SaveSufix]);
fprintf('\n\nSaving file: %s\n', Filename);
save(Filename);
