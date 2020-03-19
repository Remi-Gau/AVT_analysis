
clear
clc
close all

StartDir = fullfile(pwd, '..','..','..','..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
cd (StartDir)

NbLayers = 6;

ROIs= {...
    'V1-thres',...
    'V2-thres',...
    'V3-thres',...
    'V4-thres',...
    'V5-thres',...
    'A1', ...
    'PT'
    };

% Options for the SVM
[opt, ~] = get_mvpa_options();

SaveSufix = CreateSaveSufix(opt, [], NbLayers);
SaveSufix = strrep(SaveSufix, '_', '-');

MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM','vol');
DestFigDir = fullfile(MVPAFigDir,'compiled');
mkdir(DestFigDir)


%%
MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM', 'vol');

for Perm = 0:1
    
    if Perm
        suffix = '_perm';
    else
        suffix = '_ttest';
    end
    
    for iROI=1:numel(ROIs)
        
        cd(MVPAFigDir)
        
        A = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Ipsi-WholeROI-' SaveSufix(9:end-4)  suffix '.tif']);
        B = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Ipsi-' SaveSufix(9:end-4) '_6Layers'  suffix '.tif']);
        C = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Contra-WholeROI-' SaveSufix(9:end-4) suffix '.tif']);
        D = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Contra-' SaveSufix(9:end-4) '_6Layers' suffix '.tif']);
        
        Command = [];
        
        for iFile = 1:numel(A)
            disp(A(iFile).name)
            disp(B(iFile).name)
            disp(C(iFile).name)
            disp(D(iFile).name)
            Command = [Command ' ' fullfile(MVPAFigDir,A(iFile).name)]; %#ok<*AGROW>
            Command = [Command ' ' fullfile(MVPAFigDir,B(iFile).name)];
            Command = [Command ' ' fullfile(MVPAFigDir,C(iFile).name)];
            Command = [Command ' ' fullfile(MVPAFigDir,D(iFile).name)];
        end
        
        system(['convert ' Command ' ' fullfile(DestFigDir, ...
            [ROIs{iROI} '_AVT_MVPA_stims_targets_' SaveSufix(2:end-4) suffix '_' date '.pdf'])])
        
    end
    
end