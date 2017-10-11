function bold_ROI_vol_pool_hs_grp_avg
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

ResultsDir = fullfile(StartDir, 'results', 'profiles');
[~,~,~] = mkdir(ResultsDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

CondNames = {...
    'AStimL','AStimR';...
    'VStimL','VStimR';...
    'TStimL','TStimR';...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };


% ROI
ROIs= {...
    'TE',...
    'PT',...
    'S1_cyt',...
            'S1_aal',...
    'V1',...
    'V2',...
    'V3',...
    'V4',...
    'V5'};

for iROI = 1:length(ROIs)
    AllSubjects_Data(iROI) = struct(...
        'name', ROIs{iROI});
end


%% Gets data for each subject
for iSub = 1:NbSub
    
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    SaveDir = fullfile(SubDir, 'results', 'profiles');
    
    for iROI=1:numel(ROIs)
        
        File2Load = fullfile(SaveDir, strcat('Data_Pooled_', AllSubjects_Data(iROI).name, '_l-', ...
            num2str(NbLayers), '.mat'));
        
        if exist(File2Load,'file')
            
            load(File2Load, 'Data_ROI')
            
            AllSubjects_Data(iROI).Ispi.grp(iSub,:) = nanmean(Data_ROI.Ispi.WholeROI.MEAN);
            AllSubjects_Data(iROI).Contra.grp(iSub,:) = nanmean(Data_ROI.Contra.WholeROI.MEAN);
            AllSubjects_Data(iROI).Contra_VS_Ipsi.grp(iSub,:) = nanmean(Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN);
            AllSubjects_Data(iROI).ContSensModIpsi.grp(iSub,:) = nanmean(Data_ROI.ContSensModIpsi.WholeROI.MEAN);
            AllSubjects_Data(iROI).ContSensModContra.grp(iSub,:) = nanmean(Data_ROI.ContSensModContra.WholeROI.MEAN);
            
        else
            warning('The file %s does not exit.', File2Load)

            AllSubjects_Data(iROI).Ispi.grp(iSub,:) = nan(1, size(CondNames,1));
            AllSubjects_Data(iROI).Contra.grp(iSub,:) = nan(1, size(CondNames,1));
            AllSubjects_Data(iROI).Contra_VS_Ipsi.grp(iSub,:) =  nan(1, size(CondNames,1));
            AllSubjects_Data(iROI).ContSensModIpsi.grp(iSub,:) =  nan(1, size(CondNames,1));
            AllSubjects_Data(iROI).ContSensModContra.grp(iSub,:) =  nan(1, size(CondNames,1));
            
        end
        
        clear Data_ROI
        
    end
end



%% Averages over subjects
for iROI=1:length(AllSubjects_Data)
    
    fprintf(' Processing %s\n', AllSubjects_Data(iROI).name)
    
    AllSubjects_Data(iROI).Ispi.MEAN = nanmean(AllSubjects_Data(iROI).Ispi.grp);
    AllSubjects_Data(iROI).Ispi.STD = nanstd(AllSubjects_Data(iROI).Ispi.grp);
    AllSubjects_Data(iROI).Ispi.SEM = nansem(AllSubjects_Data(iROI).Ispi.grp);
    
    AllSubjects_Data(iROI).Contra.MEAN = nanmean(AllSubjects_Data(iROI).Contra.grp);
    AllSubjects_Data(iROI).Contra.STD = nanstd(AllSubjects_Data(iROI).Contra.grp);
    AllSubjects_Data(iROI).Contra.SEM = nansem(AllSubjects_Data(iROI).Contra.grp);
    
    AllSubjects_Data(iROI).Contra_VS_Ipsi.MEAN = nanmean(AllSubjects_Data(iROI).Contra_VS_Ipsi.grp);
    AllSubjects_Data(iROI).Contra_VS_Ipsi.STD = nanstd(AllSubjects_Data(iROI).Contra_VS_Ipsi.grp);
    AllSubjects_Data(iROI).Contra_VS_Ipsi.SEM = nansem(AllSubjects_Data(iROI).Contra_VS_Ipsi.grp);
    
    AllSubjects_Data(iROI).ContSensModIpsi.MEAN = nanmean(AllSubjects_Data(iROI).ContSensModIpsi.grp);
    AllSubjects_Data(iROI).ContSensModIpsi.STD = nanstd(AllSubjects_Data(iROI).ContSensModIpsi.grp);
    AllSubjects_Data(iROI).ContSensModIpsi.SEM = nansem(AllSubjects_Data(iROI).ContSensModIpsi.grp);
    
    AllSubjects_Data(iROI).ContSensModContra.MEAN = nanmean(AllSubjects_Data(iROI).ContSensModContra.grp);
    AllSubjects_Data(iROI).ContSensModContra.STD = nanstd(AllSubjects_Data(iROI).ContSensModContra.grp);
    AllSubjects_Data(iROI).ContSensModContra.SEM = nansem(AllSubjects_Data(iROI).ContSensModContra.grp);
    
end


%% Saves
fprintf('\nSaving\n')

save( fullfile(ResultsDir, strcat('ResultsVolBOLDPoolWholeROI.mat')) )

cd(StartDir)

end
