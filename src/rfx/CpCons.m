clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = [2 4] % 1:NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    [~, ~, ~] = mkdir(fullfile(StartDir, SubLs(iSub).name, 'ffx_nat_smooth', 'con'));

    copyfile(fullfile(StartDir, SubLs(iSub).name, 'ffx_nat_smooth', 'con*.nii'), ...
             fullfile(StartDir, SubLs(iSub).name, 'ffx_nat_smooth', 'con'));

    copyfile(fullfile(StartDir, SubLs(iSub).name, 'meanusub-*_ses-*_task-audiovisualtactile_run-*_bold.nii'), ...
             fullfile(StartDir, SubLs(iSub).name, 'ffx_nat_smooth', 'con'));

end
