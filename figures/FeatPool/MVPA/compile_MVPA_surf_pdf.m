clear
clc
close all

StartDir = fullfile(pwd, '..','..','..', '..');
cd (StartDir)

Perm = 0;
if Perm
    suffix = '_perm';
else
    suffix = '_ttest'; %#ok<*UNRCH>
end

ROIs= {...
    'V1',...
    'V2',...
    'V3',...
    'V4',...
    'V5',...
    'A1', ...
    'PT'
    };

opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;

NbLayers = 6;


%%
MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM','surf');
DestFigDir = fullfile(MVPAFigDir,'compiled');
mkdir(DestFigDir)

for Norm = 5:7
    
    switch Norm
        case 5
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 0;
            opt.scaling.feat.range = 1;
            opt.scaling.feat.sessmean = 0;
        case 6
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 1;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 0;
        case 7
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 1;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 0;
    end
    
    SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
    SaveSufix = strrep(SaveSufix, '_', '-');
    
    for iROI=1:numel(ROIs)
        
        cd(MVPAFigDir)
        A = dir([strrep(ROIs{iROI}, '_', '-')  '-Contra-vs-Ipsi-' SaveSufix(9:end-4)  suffix '.pdf']);
        B = dir([strrep(ROIs{iROI}, '_', '-')  '-Contra-vs-Ipsi-' SaveSufix(9:end-4) '_6Layers' suffix '.pdf']);
        C = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Ipsi-' SaveSufix(9:end-4)  suffix '.pdf']);
        D = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Ipsi-' SaveSufix(9:end-4) '_6Layers' suffix '.pdf']);
        E = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Contra-' SaveSufix(9:end-4)  suffix '.pdf']);
        F = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Contra-' SaveSufix(9:end-4) '_6Layers' suffix '.pdf']);
        
        Command = [];
        
        for iFile = 1:numel(A)
            disp(A(iFile).name)
            disp(B(iFile).name)
            disp(C(iFile).name)
            disp(D(iFile).name)
            disp(E(iFile).name)
            disp(F(iFile).name)
            
            Command = [Command ' ' fullfile(MVPAFigDir,A(iFile).name)]; %#ok<*AGROW>
            Command = [Command ' ' fullfile(MVPAFigDir,B(iFile).name)];
            Command = [Command ' ' fullfile(MVPAFigDir,C(iFile).name)];
            Command = [Command ' ' fullfile(MVPAFigDir,D(iFile).name)];
            Command = [Command ' ' fullfile(MVPAFigDir,E(iFile).name)];
            Command = [Command ' ' fullfile(MVPAFigDir,F(iFile).name)];
            
        end
        
        system([...
            'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
            '-sOutputFile=' fullfile(DestFigDir, ...
            [ROIs{iROI} '_AVT_MVPA_' SaveSufix(2:end-4) suffix '_' date '.pdf']) ' ' Command])
        
    end
    
end