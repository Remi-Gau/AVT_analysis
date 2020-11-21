% (C) Copyright 2020 Remi Gau
%%
%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

Surf2Load = { ...
             'IPL_6_6'; ...
             'PoG_4_2'; ...
             'PrG_6_5'; ...
             'STG_6_1'; ...
             'STG_6_2'; ... %PT
             'STG_6_3'; ...
             'STG_6_4'; ...
             'STG_6_5'; ...
             'STG_6_6'};

Thresh = 40;

for iSub = 1:NbSub

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    for hs = 1:2
        %% Get inflated surface
        if hs == 1
            fprintf(' Left HS\n');
            suffix = 'l';
        else
            fprintf(' Right HS\n');
            suffix = 'r';
        end

        Inf_file = spm_select('FPList', fullfile(SubDir, 'anat', 'cbs'), ...
                              ['^' SubLs(iSub).name '.*' suffix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex, inf_face, ~] = read_vtk(Inf_file, 0, 1);

        %% Get data

        PT_vtk = spm_select('FPList', fullfile(SubDir, 'pmap'), ...
                            ['^' SubLs(iSub).name '.*' suffix 'cr_gm_avg_' Surf2Load{5} '.vtk$']);
        [~, ~, PT] = read_vtk(PT_vtk, 0, 1);

        OtherROI = [];
        for iROI = [1:4 6:9]
            vtk = spm_select('FPList', fullfile(SubDir, 'pmap'), ...
                             ['^' SubLs(iSub).name '.*' suffix 'cr_gm_avg_' Surf2Load{iROI} '.vtk$']);
            [~, ~, tmp] = read_vtk(vtk, 0, 1);
            OtherROI(end + 1, :) = tmp; %#ok<SAGROW>
        end
        SumOther = sum(OtherROI);

        A1 = spm_select('FPList', fullfile(SubDir, 'roi', 'surf'), ...
                        ['^' SubLs(iSub).name '_A1_' suffix 'cr_RG_UN.vtk$']);
        [~, ~, A1] = read_vtk(A1, 0, 1);

        if ~sum(A1 == 2) == 0
            A1(A1 == 1) = 0;
            A1(A1 == 2) = 1;
        end
        write_vtk(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name '_A1_' suffix 'cr.vtk']), inf_vertex, inf_face, A1);

        for iThres = 1:numel(Thresh)
            Mapping = zeros(1, size(PT, 2));

            Mapping(1, PT > Thresh(iThres)) = 1;
            Mapping(1, SumOther > PT) = 0;
            Mapping(1, A1 > 0) = 0;

            write_vtk(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name '_PT_' suffix 'cr.vtk']), inf_vertex, inf_face, Mapping);
        end

        clear Mapping A1 PT OtherROI inf_vertex inf_face PT_vtk vtk Inf_file;

    end

end
