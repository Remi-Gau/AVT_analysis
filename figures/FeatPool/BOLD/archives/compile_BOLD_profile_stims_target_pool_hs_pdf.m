+clear
clc
close all

StartDir = fullfile(pwd, '..','..','..','..');
cd (StartDir)

Perm = 0;
if Perm
    suffix = '_perm';
else
    suffix = '_ttest';
end

% ROIs= {...
%     'V1',...
%     'V2',...
%     'V3',...
%     'V4',...
%     'V5',...
%     'TE', ...
%     'PT',...
%     'S1_cyt',...
%         'S1_aal',...
% };

ROIs= {...
'A1',...
'V1_thres',...
'V2_thres',...
'V3_thres',...
'V4_thres',...
'V5_thres',...
'PT'};

%%
ProfileFigDir = fullfile(StartDir, 'figures', 'profiles', 'vol');
mkdir(fullfile(ProfileFigDir, 'compiled'))

for iROI=1:numel(ROIs)
    
    clear FileList
    
    cd(ProfileFigDir)
%     FileList(1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Conditions_6Layers' suffix '.pdf']);
    FileList(1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Ipsilateral_6Layers' suffix '.pdf']); %#ok<*SAGROW>
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-StimVsTargets-Ipsilateral_6Layers' suffix '.pdf']); 
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Contralateral_6Layers' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-StimVsTargets-Contralateral_6Layers' suffix '.pdf']);   
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-Ipsi-Contra_6Layers' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-SensModContrastsIpsi_6Layers' suffix '.pdf']);
    FileList(end+1) = dir([strrep(ROIs{iROI}, '_', '-') '-Targets-SensModContrastsContra_6Layers' suffix '.pdf']);
    
    Command = [];
    
    for iFile = 1:numel(FileList)
        
        disp(FileList(iFile).name)
        Command = [Command ' ' fullfile(ProfileFigDir,FileList(iFile).name)]; %#ok<*AGROW>

    end
    
    system([...
        'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
        '-sOutputFile=' fullfile(ProfileFigDir, 'compiled', ...
        [ROIs{iROI} '_AVT_Targets_BOLD_FeatPool_Layers-6_' suffix '_' date '.pdf']) ' ' Command])
    
end