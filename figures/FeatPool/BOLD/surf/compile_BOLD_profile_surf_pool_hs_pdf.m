clear
clc
close all

StartDir = fullfile(pwd, '..','..','..','..','..');
cd (StartDir)

Perm = 0;
if Perm
    suffix = '_perm';
else
    suffix = '_ttest';
end

ROIs= {...
'A1',...
'V1',...
'V2',...
'V3',...
'V4',...
'V5',...
'PT'};

%%
ProfileFigDir = fullfile(StartDir, 'figures', 'profiles','surf');
DestFigDir = fullfile(ProfileFigDir,'compiled');
mkdir(DestFigDir)

for iROI=1:numel(ROIs)
    
    clear FileList
    
    cd(ProfileFigDir)
%     FileList(1) = dir([strrep(ROIs{iROI}, '_', '-') '-Conditions_6Layers' suffix '.pdf']);
    FileList(1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Ipsilateral' suffix '.pdf']); %#ok<*SAGROW>
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Ipsilateral_6Layers' suffix '.pdf']); %#ok<*SAGROW>
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Contralateral' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Contralateral_6Layers' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Contra-Ipsi' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Contra-Ipsi_6Layers' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-SensModContrasts-Ipsi' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-SensModContrasts-Ipsi_6Layers' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-SensModContrasts-Contra' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-SensModContrasts-Contra_6Layers' suffix '.pdf']);
    
    FileList_tif(1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Ipsilateral' suffix '.tif']); %#ok<*SAGROW>
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Ipsilateral_6Layers' suffix '.tif']); %#ok<*SAGROW>
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Contralateral' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Contralateral_6Layers' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Contra-Ipsi' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Contra-Ipsi_6Layers' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-SensModContrasts-Ipsi' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-SensModContrasts-Ipsi_6Layers' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-SensModContrasts-Contra' suffix '.tif']);
    FileList_tif(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-SensModContrasts-Contra_6Layers' suffix '.tif']);
    
    Command = [];
    Command_tif = [];
    
    for iFile = 1:numel(FileList)
        
        disp(FileList(iFile).name)
        Command = [Command ' ' fullfile(ProfileFigDir,FileList(iFile).name)]; %#ok<*AGROW>
        Command_tif = [Command_tif ' ' fullfile(ProfileFigDir,FileList_tif(iFile).name)]; %#ok<*AGROW>

    end
    
    system(['convert ' Command_tif ' ' fullfile(DestFigDir, [ROIs{iROI} '_AVT_BOLD_FeatPool_Layers-6' suffix '_' date '.pdf'])])
    
    system([...
        'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
        '-sOutputFile=' fullfile(DestFigDir, ...
        [ROIs{iROI} '_AVT_BOLD_FeatPool_Layers-6' suffix '_' date '.pdf']) ' ' Command])
    
end