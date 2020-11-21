% function MVPA_plot

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

        load(fullfile(Dirs.MVPA_resultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')), 'SVM');

    end

    for iSVM = 1:numel(SVM)

        fprintf('\n%s', SVM(iSVM).name);

        for iROI = 1:numel(ROIs_ori)

            [~, P] = ttest(SVM(iSVM).ROI(iROI).grp, .5);

            fprintf('\n%s: %.2f +/- %.2f ; p = %.3f', ...
                    SVM(iSVM).ROI(iROI).name, ...
                    SVM(iSVM).ROI(iROI).MEAN, ...
                    SVM(iSVM).ROI(iROI).STD, ...
                    P);
        end

        fprintf('\n');
    end

end

% end
