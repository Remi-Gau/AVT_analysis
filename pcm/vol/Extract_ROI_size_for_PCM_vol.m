function Extract_ROI_size_for_PCM_vol
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ROIs = {...
    'A1%',...
    'PT%',...
    'V1%_thres',...
    'V2%_thres',...
    'V3%_thres',...
    'V4%_thres',...
    'V5%_thres',...
    };

NbLayers = 6;
FWHM = 0;

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    AnalysisFolder = fullfile(SubDir, 'ffx_nat', 'betas');
    
    SaveDir = fullfile(SubDir,'results','PCM','vol');
    mkdir(SaveDir)
    
    %% Mask each image by each ROI and create a features set (images x voxel)
    fprintf('\n Get features\n')
    
    HS = 'LR';
    for iROI=1:length(ROIs)
        for iHS = 1:length(HS)
            FeatureFile = fullfile(AnalysisFolder, ['Features_' strrep(ROIs{iROI},'%', ['_' HS(iHS)])  ...
                '_l-' num2str(NbLayers) '_s-' num2str(FWHM)  '.mat']);
            
            load(FeatureFile,'MaskSave')
            
            ROI_size(iROI,iHS) = MaskSave.size;
        end
        
    end

    save(fullfile(SaveDir,'ROI_size_PCM.mat'), 'ROI_size', 'ROIs')
    
    clear Features
    
end

