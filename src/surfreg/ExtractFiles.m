clear;
clc;

hs = 'lr';

StartDir = fullfile(pwd, '..', '..');
cd(StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

DataFolder = fullfile(StartDir, 'surfreg', 'GrpAvgBOLD');

%%

for ihs = 1:numel(hs)

    % Extract basic surfaces
    copyfile(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'exp-0000', 'exp-0000-A', 'SurfaceMeshInflation', '*.vtk'), DataFolder);

    cd(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'exp-0000'));
    FoldersList = dir('*.input');

    for iFile = 1:numel(FoldersList)

        clear Content pat Stim Att Layer;

        cd(FoldersList(iFile).name(1:end - 6));
        disp(FoldersList(iFile).name(1:end - 6));

        tmp = dir('SurfaceMeshGroupData');

        if ~isempty(tmp)

            Content = fileread('SurfaceMeshGroupData.input');

            pat = '[AVT]Stim[LR]_layer_\d';
            Stim = regexp(Content, pat, 'match');
            Stim = Stim{1};

            disp(Stim);

            SurfFile = spm_select('FPList', fullfile(pwd, 'SurfaceMeshGroupData'), ...
                                  ['^Surface_ls_low_res_' hs(ihs) 'h_trgsurf_groupdata.vtk$']);

            copyfile(SurfFile, fullfile(DataFolder,  [upper(hs(ihs)) 'H'], ...
                                        ['GrpSurf_' Stim '_' hs(ihs) 'h.vtk']));

            clear SurfFile;
        end

        cd ..;
    end

end
