clear; clc

StartFolder = fullfile(pwd, '..', '..');
cd(StartFolder)

SubjectList = [...
    '02';...
    '03';...
    '04';...
    '06';...    
    '07';...
    '08';...
    '09';...
    '11';...
    '12';...
    '13';...
    '14';...    
    '15';...
    '16'
    ];

for SubjInd = 1:size(SubjectList,1)
    
    SubjID = SubjectList(SubjInd,:);
    
    SubjectFolder = fullfile(StartFolder, 'Subjects_Data', ['Subject_' SubjID], 'Structural', 'CBS');
    
    LevelSetFile = dir(fullfile(SubjectFolder, ...
        ['T1_' SubjID '_thresh_clone_transform_strip_clone_transform_bound_mems_cr_gm_avg.nii']));
    
    if ~exist(fullfile(SubjectFolder,LevelSetFile.name), 'file')
        gunzip(fullfile(SubjectFolder,[LevelSetFile.name '.gz']))
    end

    tmp = spm_read_vols(spm_vol(fullfile(SubjectFolder,LevelSetFile.name)));
    
    LevetSetVols(:,SubjInd) = tmp(:);

    clear LevelSetFile SubjectFolder SubjID tmp 
    
end
clear SubjInd



MeanLevetSet = mean(LevetSetVols,2);

MAD = abs(LevetSetVols-repmat(MeanLevetSet, [1,size(LevetSetVols,2)]));
MAD = mean(MAD);
[MIN,I]=min(MAD);

SubjectList(I,:)





