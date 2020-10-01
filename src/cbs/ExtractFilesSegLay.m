clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 2:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    TargetDir = fullfile(StartDir, SubLs(iSub).name, 'anat', 'cbs');
    SrcDir = fullfile(TargetDir, 'segment_layer', 'exp-0000');
    cd(TargetDir);

    % Structural
    copyfile(fullfile(SrcDir, 'exp-0000-CADA', 'Intensity_Bounds', ...
                      'sub-*_transform_bound.nii.gz'), fullfile(TargetDir));

    % Surfaces
    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAAAAA', 'SurfaceMeshInflation', ...
                          '*.vtk'), fullfile(TargetDir));
    catch
    end
    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAABAA', 'SurfaceMeshInflation', ...
                          '*.vtk'), fullfile(TargetDir));
    catch
    end

    % T1 mappings
    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAB', 'SurfaceMeshMapping', ...
                          '*.vtk'), fullfile(TargetDir));
    catch
    end
    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAC', 'SurfaceMeshMapping', ...
                          '*.vtk'), fullfile(TargetDir));
    catch
    end

    % Layerlabels
    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAACAAA', 'RenameImage', ...
                          '*.gz'), fullfile(TargetDir));
    catch
        copyfile(fullfile(SrcDir, 'exp-0000-CADAACAA', 'VolumetricLayering', '*labels.nii.gz'), ...
                 fullfile(TargetDir));
        file = dir(fullfile(TargetDir, '*labels.nii.gz'));
        movefile(fullfile(TargetDir, file.name), ...
                 fullfile(TargetDir, [SubLs(iSub).name '_MP2RAGE_T1map_Layers-03.nii.gz']));
    end

    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAACACA', 'RenameImage', ...
                          '*.gz'), fullfile(TargetDir));
    catch
        copyfile(fullfile(SrcDir, 'exp-0000-CADAACAC', 'VolumetricLayering', '*labels.nii.gz'), ...
                 fullfile(TargetDir));
        file = dir(fullfile(TargetDir, '*labels.nii.gz'));
        movefile(fullfile(TargetDir, file.name), ...
                 fullfile(TargetDir, [SubLs(iSub).name '_MP2RAGE_T1map_Layers-06.nii.gz']));
    end

    try
        movefile(fullfile(SrcDir, 'exp-0000-CADAACAEA', 'RenameImage', ...
                          '*.gz'), fullfile(TargetDir));
    catch
        copyfile(fullfile(SrcDir, 'exp-0000-CADAACAE', 'VolumetricLayering', '*labels.nii.gz'), ...
                 fullfile(TargetDir));
        file = dir(fullfile(TargetDir, '*labels.nii.gz'));
        movefile(fullfile(TargetDir, file.name), ...
                 fullfile(TargetDir, [SubLs(iSub).name '_MP2RAGE_T1map_Layers-10.nii.gz']));
    end

    gunzip(fullfile(TargetDir, 'sub-*_transform_bound.nii.gz'));

    cd (StartDir);

end
