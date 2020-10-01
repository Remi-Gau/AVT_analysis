clear;
clc;

spm_get_defaults;
global defaults %#ok<NUSED>

flags = struct( ...
               'sep', [2 1 0.7 0.4], ...
               'params',  [0 0 0  0 0 0], ...
               'cost_fun', 'nmi', ...
               'tol', [repmat(0.001, 1, 3), repmat(0.0005, 1, 3), repmat(0.005, 1, 3), repmat(0.0005, 1, 3)], ...
               'fwhm', [5, 5], ...
               'graphics', ~spm('CmdLine'));

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 2:NbSub

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    Img2Process = {};
    TargetScan = []; %#ok<NASGU>
    SourceScan = []; %#ok<NASGU>

    TargetScan = dir(fullfile(SubDir, 'anat', 'cbs', ...
                              [SubLs(iSub).name '*_bound.nii']));
    TargetScan = fullfile(SubDir, 'anat', 'cbs', ...
                          TargetScan.name);

    cd(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    SourceScan = dir(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', ...
                              'msub*.nii'));
    SourceScan = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', ...
                          SourceScan.name);

    tmp = dir('w*.nii');
    for iFile = 1:length(tmp)
        Img2Process{end + 1, 1} = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', tmp(iFile).name); %#ok<SAGROW>
    end

    spm_coreg_reorient_save(TargetScan, SourceScan, Img2Process, flags);

end

cd(StartDir);
