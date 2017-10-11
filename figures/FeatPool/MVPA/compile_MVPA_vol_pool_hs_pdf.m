
clear
clc
close all

StartDir = fullfile(pwd, '..','..','..','..');
cd (StartDir)

ROIs= {...
    'V1',...
    'V2',...
    'V3',...
    'TE', ...
    'PT',...
    'S1_aal',...
    'S1_cyt',...
    };

%     'V4',...
%     'V5',...
%     'pSTG',...    

%%
MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM');

for iROI=1:numel(ROIs)
    
    cd(MVPAFigDir)
    A = dir([strrep(ROIs{iROI}, '_', '-') '-ipsiVScontra_6Layers.pdf']);
    B = dir([strrep(ROIs{iROI}, '_', '-') '-BetweenSensesIpsi_6Layers.pdf']);
    C = dir([strrep(ROIs{iROI}, '_', '-') '-BetweenSensesContra_6Layers.pdf']);
    
    Command = [];
    
    for iFile = 1:numel(A)
        disp(A(iFile).name)
        disp(B(iFile).name)
        disp(C(iFile).name)
        Command = [Command ' ' fullfile(MVPAFigDir,A(iFile).name)]; %#ok<*AGROW>
        Command = [Command ' ' fullfile(MVPAFigDir,B(iFile).name)]; %#ok<*AGROW>
        Command = [Command ' ' fullfile(MVPAFigDir,C(iFile).name)]; %#ok<*AGROW>
    end
    
    system([...
        'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
        '-sOutputFile=' fullfile(StartDir, 'figures', ...
        [ROIs{iROI} '_AVT_MVPA_FeatPool_Idpdt-IMG-ZScore-FEAT-MeanCent-FWHM-0-Layers-6_' date '.pdf']) ' ' Command])
    
end