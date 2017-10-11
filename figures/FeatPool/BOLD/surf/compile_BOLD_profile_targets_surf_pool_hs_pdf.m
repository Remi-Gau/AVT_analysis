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
    FileList(1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Targets-Ipsilateral' suffix '.pdf']); %#ok<*SAGROW>
    FileList(end+1) =  dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-StimVsTargets-Ipsilateral' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Ipsilateral_6Layers' suffix '.pdf']); 
    FileList(end+1) =  dir([strrep(ROIs{iROI}, '_', '-') '-StimVsTargets-Ipsilateral_6Layers' suffix '.pdf']);
    
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Targets-Contralateral' suffix '.pdf']);
    FileList(end+1) =  dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-StimVsTargets-Contralateral' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Contralateral_6Layers' suffix '.pdf']);
    FileList(end+1) =  dir([strrep(ROIs{iROI}, '_', '-') '-StimVsTargets-Contralateral_6Layers' suffix '.pdf']);
    
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Targets-Contra-Ipsi' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Contra-Ipsi_6Layers' suffix '.pdf']);
    
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Targets-SensModContrasts-Ipsi' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-SensModContrasts-Ipsi_6Layers' suffix '.pdf']);
    
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-WholeROI-Targets-SensModContrasts-Contra' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-SensModContrasts-Contra_6Layers' suffix '.pdf']);
    

    Command = [];
    
    for iFile = 1:numel(FileList)
        
        disp(FileList(iFile).name)
        Command = [Command ' ' fullfile(ProfileFigDir,FileList(iFile).name)]; 

    end
    
    system([...
        'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
        '-sOutputFile=' fullfile(DestFigDir, ...
        [ROIs{iROI} '_AVT_BOLD_Targets_FeatPool_Layers-6' suffix '_' date '.pdf']) ' ' Command])
    
end