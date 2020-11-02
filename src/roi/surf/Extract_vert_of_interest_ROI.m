clear;
clc;

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 2:NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    for hs = 1:2

        if hs == 1
            HsPrefix = 'l';
            fprintf(' Left HS\n');
        else
            HsPrefix = 'r';
            fprintf(' Right HS\n');
        end

        %% Get surface
        vtk = spm_select('FPList', fullfile(SubDir, 'anat', 'cbs'), ...
                         ['^' SubLs(iSub).name '.*' HsPrefix 'cr_gm_avg.vtk$']);
        [vertex, faces, ~] = read_vtk(vtk, 0, 1);

        NbVertex(hs) = size(vertex, 2); %#ok<*SAGROW>

        vtk = spm_select('FPList', fullfile(SubDir, 'anat', 'cbs'), ...
                         ['^' SubLs(iSub).name '.*' HsPrefix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex, inf_faces, ~] = read_vtk(vtk, 0, 1);

        %% A1
        vtk = spm_select('FPList', fullfile(SubDir, 'roi', 'surf'), ...
                         ['^' SubLs(iSub).name '_A1_' HsPrefix 'cr.vtk$']);
        if isempty(vtk)
            error('Could not find the ROI vtk file.');
        end
        [~, ~, mapping] = read_vtk(vtk, 0, 1);

        fprintf('  A1\n');
        if numel(mapping) ~= NbVertex(hs)
            warning('The number of vertices does not match.');
            numel(mapping);
            NbVertex(hs);
        end
        disp(unique(mapping));

        ROI(1).name = 'A1';
        ROI(1).VertOfInt{hs} = find(mapping > 0);
        clear mapping;

        %% PT
        vtk = spm_select('FPList', fullfile(SubDir, 'roi', 'surf'), ...
                         ['^' SubLs(iSub).name '_PT_' HsPrefix 'cr.vtk$']);
        if isempty(vtk)
            error('Could not find the ROI vtk file.');
        end
        [~, ~, mapping] = read_vtk(vtk, 0, 1);

        fprintf('  PT\n');
        if numel(mapping) ~= NbVertex(hs)
            warning('The number of vertices does not match.');
            numel(mapping);
            NbVertex(hs);
        end
        disp(unique(mapping));

        ROI(2).name = 'PT';
        ROI(2).VertOfInt{hs} = find(mapping == 1);
        clear mapping;

        %% Visual ROIs
        for iROI = 1:5
            vtk = spm_select('FPList', fullfile(SubDir, 'pmap'), ...
                             ['^' SubLs(iSub).name '_' HsPrefix 'cr_V' num2str(iROI) '_Pmap_Ret_thres_10.vtk$']);
            if isempty(vtk)
                error('Could not find the ROI vtk file.');
            end
            [~, ~, mapping] = read_vtk(vtk, 0, 1);

            fprintf('  V%i\n', iROI);
            if numel(mapping) ~= NbVertex(hs)
                warning('The number of vertices does not match.');
                numel(mapping);
                NbVertex(hs);
            end
            disp(unique(mapping));

            ROI(2 + iROI).name = ['V' num2str(iROI)];
            ROI(2 + iROI).VertOfInt{hs} = find(mapping == 1);

            clear mapping;
        end

        %%
        cd(fullfile(SubDir, 'roi', 'surf'));
        mapping = zeros(1, size(vertex, 2));
        mapping(ROI(1).VertOfInt{hs}) = 1;
        mapping(ROI(2).VertOfInt{hs}) = 2;
        for iROI = 1:5
            mapping(ROI(2 + iROI).VertOfInt{hs}) = iROI + 2;
        end
        write_vtk([SubLs(iSub).name '_' HsPrefix 'cr_AllROIs.vtk'], inf_vertex, inf_faces, mapping);

    end

    %%
    save(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    clear NbVertex ROI;

end

cd(StartDir);
