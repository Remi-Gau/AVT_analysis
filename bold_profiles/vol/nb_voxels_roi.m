function nb_voxels_roi
clc; clear;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)

ResultsDir = fullfile(StartDir, 'results', 'profiles');
[~,~,~] = mkdir(ResultsDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

% ROI
ROIs= {...
    'A1_L',...
    'V1_L_thres',...
    'V2_L_thres',...
    'V3_L_thres',...
    'V4_L_thres',...
    'V5_L_thres',...
    'PT_L',...
    'S1_L_cyt',...
    'S1_L_aal',...
    'A1_R',...
    'V1_R_thres',...
    'V2_R_thres',...
    'V3_R_thres',...
    'V4_R_thres',...
    'V5_R_thres',...
    'PT_R',...
    'S1_R_cyt',...
    'S1_R_aal'};


for iROI = 1:length(ROIs)
    AllSubjects_Data(iROI) = struct(...
        'name', ROIs{iROI}); %#ok<*AGROW>
end


%% Gets data for each subject
for iSub = 1:NbSub
    
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    SaveDir = fullfile(SubDir, 'results', 'profiles');
    
    for iROI=1:numel(ROIs)
        
        File2Load = fullfile(SaveDir, strcat('Data_', AllSubjects_Data(iROI).name, '_l-', ...
            num2str(NbLayers), '.mat'));
        
        if exist(File2Load,'file')
            
            load(File2Load, 'Data_ROI')
            
            AllSubjects_Data(iROI).size.data(iSub,:) = Data_ROI.info.size;
            AllSubjects_Data(iROI).vox_per_layer.data(:,iSub) = Data_ROI.info.vox_per_layer(:,2);
            
        else
            warning('The file %s does not exit.', File2Load)
            
            AllSubjects_Data(iROI).size.data(iSub) = nan;
            AllSubjects_Data(iROI).vox_per_layer.data(:,iSub) = nan(NbLayers,2);

        end
        
        clear Data_ROI
        
    end
end



%% Averages over subjects
for iROI=1:length(AllSubjects_Data)
    
    fprintf(' Processing %s\n', AllSubjects_Data(iROI).name)
    
    AllSubjects_Data(iROI).size.MEAN = nanmean(AllSubjects_Data(iROI).size.data);
    AllSubjects_Data(iROI).size.STD = nanstd(AllSubjects_Data(iROI).size.data);
    AllSubjects_Data(iROI).size.SEM = nansem(AllSubjects_Data(iROI).size.data);
    
    AllSubjects_Data(iROI).vox_per_layer.MEAN = nanmean(AllSubjects_Data(iROI).vox_per_layer.data,2);
    AllSubjects_Data(iROI).vox_per_layer.STD = nanstd(AllSubjects_Data(iROI).vox_per_layer.data,2);
    AllSubjects_Data(iROI).vox_per_layer.SEM = nansem(AllSubjects_Data(iROI).vox_per_layer.data,2);
    
    
end


save( fullfile(ResultsDir, strcat('NbVoxels_l-', num2str(NbLayers), '.mat')) )


cd(StartDir)

end

