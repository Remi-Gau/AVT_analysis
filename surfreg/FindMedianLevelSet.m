clear; clc

StartDir = fullfile(pwd, '..', '..');
cd(StartDir)

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    SubDir = fullfile(StartDir, SubLs(iSub).name, 'anat', 'cbs');
    
    for hs = 1:2
        
        if hs==1
            suffix='l';
        else
            suffix='r';
        end
        
        LevelSetFile = spm_select('FPList', SubDir, ...
            ['^*MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_' suffix 'cr_gm_avg.nii$']);
        
        if isempty(LevelSetFile)
            gunzip(spm_select('FPList', SubDir, ...
            ['^*MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_' suffix 'cr_gm_avg.nii.gz$']))
            
            LevelSetFile = spm_select('FPList', SubDir, ...
            ['^*MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_' suffix 'cr_gm_avg.nii$']);
        end
        
        tmp = spm_read_vols(spm_vol(LevelSetFile));
        
        LevetSetVols(:,iSub,hs) = tmp(:); %#ok<SAGROW>
        
    end
    
    clear LevelSetFile SubjectFolder SubjID tmp
    
end
clear SubjInd


for hs = 1:2
    
    MeanLevetSet = mean(LevetSetVols(:,:,hs),2);
    
    if hs==1
        suffix='l';
    else
        suffix='r';
    end
    
    fprintf(['\n' suffix 'hs\n'])
    MAD = abs(LevetSetVols(:,:,hs)-repmat(MeanLevetSet, [1,size(LevetSetVols,2)]));
    MAD = mean(MAD);
    [MIN,I]=min(MAD);
    
    disp(SubLs(I).name)
    
end





