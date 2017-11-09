clear
clc
close all

StartDir = fullfile(pwd, '..','..','..','..');
cd (StartDir)

ROIs= {...
    'V1',...
    'V2',...
    'V3',...
    'V4',...
    'V5',...
    'TE', ...
    'PT',...
    'S1_cyt',...
        'S1_aal',...
};

%%
ProfileFigDir = fullfile(StartDir, 'figures', 'profiles');

for iROI=1:numel(ROIs)
    
    clear FileList
    
    cd(ProfileFigDir)
    FileList(1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-Conditions.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-Ipsilateral.pdf']); %#ok<*SAGROW>
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-Contralateral.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-Ipsi-Contra.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-SensoryModalities.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-SensModContrasts.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-SensModContrastsIpsi.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '*-WholeROI-SensModContrastsContra.pdf']);
    
    Command = [];
    
    for iFile = 1:numel(FileList)
        
        disp(FileList(iFile).name)
        Command = [Command ' ' fullfile(ProfileFigDir,FileList(iFile).name)]; %#ok<*AGROW>

    end
    
    system([...
        'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
        '-sOutputFile=' fullfile(StartDir, 'figures', ...
        [ROIs{iROI} '_AVT_Results_ROI_pool_' date '.pdf']) ' ' Command])
    
end