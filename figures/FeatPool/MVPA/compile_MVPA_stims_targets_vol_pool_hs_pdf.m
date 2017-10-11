
clear
clc
close all

StartDir = fullfile(pwd, '..','..','..','..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
cd (StartDir)

Perm = 0;
if Perm
    suffix = '_perm';
else
    suffix = '_ttest'; %#ok<*UNRCH>
end

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

opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.layersubsample.do = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;

opt.scaling.img.eucledian = 0;
opt.scaling.img.zscore = 1;
opt.scaling.feat.mean = 1;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;

SaveSufix = CreateSaveSufix(opt, [], NbLayers);
SaveSufix = strrep(SaveSufix, '_', '-');

MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM','vol');
DestFigDir = fullfile(MVPAFigDir,'compiled');
mkdir(DestFigDir)


%%
MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM', 'vol');

for iROI=1:numel(ROIs)
    
    cd(MVPAFigDir)
    
    A = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Ipsi-WholeROI-' SaveSufix(9:end-4)  suffix '.pdf']);
    B = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Ipsi-' SaveSufix(9:end-4) '_6Layers'  suffix '.pdf']);
    C = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Contra-WholeROI-' SaveSufix(9:end-4) suffix '.pdf']);
    D = dir([strrep(ROIs{iROI}, '_', '-')  '-Targets-VS-Stim-Contra-' SaveSufix(9:end-4) '_6Layers' suffix '.pdf']);
    
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
    
    system([...
        'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
        '-sOutputFile=' fullfile(DestFigDir, ...
        [ROIs{iROI} '_AVT_MVPA_stims_targets_' SaveSufix(2:end-4) suffix '_' date '.pdf']) ' ' Command])
    
end