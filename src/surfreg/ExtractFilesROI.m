clear;
clc;

hs = 'lr';

StartDir = fullfile(pwd, '..', '..');
cd(StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

DataFolder = fullfile(StartDir, 'surfreg', 'GrpAvgROI');

ROIs = {'STG_6_2' 'V1_Pmap_Ret' 'V2_Pmap_Ret' 'V3_Pmap_Ret' 'V4_Pmap_Ret' 'V5_Pmap_Ret' 'A1'};

%%

for ihs = 1:numel(hs)

    if ihs == 1
        HS_suffix = 'B';
    else
        HS_suffix = 'A';
    end

    % Extract basic surfaces
    copyfile(fullfile(DataFolder, 'exp-0000', ['exp-0000-' HS_suffix], 'SurfaceMeshInflation', '*.vtk'), DataFolder);

    cd(fullfile(DataFolder, 'exp-0000'));
    FoldersList = dir(['exp-0000-' HS_suffix '*.input']);

    for iFile = 1:numel(FoldersList)

        clear Content pat Stim Att Layer;

        cd(FoldersList(iFile).name(1:end - 6));
        disp(FoldersList(iFile).name(1:end - 6));

        tmp = dir('SurfaceMeshGroupData');

        if ~isempty(tmp)

            Content = fileread('SurfaceMeshGroupData.input');

            % '_gm_avg_\w+_data_cp_';
            % ROIs{iFile};
            % '[AVT]Targ[LR]_layer_\d';
            % '_gm_avg_*_data_cp_'

            Stim = {};
            for iROI = 1:numel(ROIs)
                pat =  ROIs{iROI};
                Stim = regexp(Content, pat, 'match');
                if numel(Stim) > 0
                    Stim = Stim{1};
                    break
                end
            end

            disp(Stim);

            SurfFile = spm_select('FPList', fullfile(pwd, 'SurfaceMeshGroupData'), ...
                                  ['^Surface_ls_low_res_' hs(ihs) 'h_trgsurf_groupdata.vtk$']);

            copyfile(SurfFile, fullfile(DataFolder, ...
                                        ['GrpSurf_' Stim '_' hs(ihs) 'h.vtk']));

            clear SurfFile;
        end

        cd ..;
    end

end
