% (C) Copyright 2020 Remi Gau
%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 8:NbSub

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    for hs = 1:2

        if hs == 1
            fprintf(' Left HS\n');
            suffix = 'l';
            copyfile(fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name, 'LA'), ...
                     fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name, 'LA.vtk'));

        else
            fprintf(' Right HS\n');
            suffix = 'r';
            copyfile(fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name, 'RA'), ...
                     fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name, 'RA.vtk'));
        end

        %% Get data
        norm_vtk = spm_select('FPList', fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name), ...
                              ['^' SubLs(iSub).name '.*' suffix 'cr_gm_avg.vtk$']);
        inf_vtk = spm_select('FPList', fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name), ...
                             ['^' SubLs(iSub).name '.*' suffix 'cr_gm_avg_inf.vtk$']);

        ROI_RG_vtk = spm_select('FPList', fullfile(StartDir, 'A1_ROI_Def', 'ROI_RG'), ...
                                ['^' SubLs(iSub).name '_A1_' suffix 'cr_RG.vtk$']);

        if hs == 1
            ROI_UN_vtk = spm_select('FPList', fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name), ...
                                    '^LA.vtk$');
        else
            ROI_UN_vtk = spm_select('FPList', fullfile(StartDir, 'A1_ROI_Def', SubLs(iSub).name), ...
                                    '^RA.vtk$');
        end

        [vertex, face, mapping] = read_vtk(inf_vtk, 0, 1);
        [norm_vertex, norm_face, mapping_norm] = read_vtk(norm_vtk, 0, 1);

        [~, ~, ROI1] = read_vtk(ROI_RG_vtk, 0, 1);
        VertOfInt1 = find(any([ROI1 == 35; ROI1 == 135]));

        [~, ~, ROI2] = read_vtk(ROI_UN_vtk, 0, 1);
        VertOfInt2 = find(any([ROI2 == 35; ROI2 == 135]));
        tabulate(ROI2);

        mapping = zeros(size(mapping));
        mapping(VertOfInt1) = mapping(VertOfInt1) + 1;
        mapping(VertOfInt2) = mapping(VertOfInt2) + 1;

        %% Get data
        mkdir(fullfile(SubDir, 'roi'));
        mkdir(fullfile(SubDir, 'roi', 'surf'));

        write_vtk(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name '_A1_' suffix 'cr_RG_UN_inf.vtk']), ...
                  vertex, ...
                  face, ...
                  mapping);
        write_vtk(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name '_A1_' suffix 'cr_RG_UN.vtk']), ...
                  norm_vertex, ...
                  norm_face, ...
                  mapping);

        clear norm_vertex vertex norm_face face mapping VertOfInt1 VertOfInt2 ROI1 ROI2 norm_vtk inf_vtk ROI_vtk;

    end

end
