clc;
clear;

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

for iSub = NbSub

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    %     DestDir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf');
    %     DestDir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf', 'targets');
    DestDir = fullfile(SubDir, 'ffx_rsa', 'betas', '6_surf');

    %% Load data or extract them
    cd(DestDir);

    % Format for reading the vertices from the VTK file
    Spec = repmat('%f ', 1, NbLayers);

    NbVertices = nan(1, 2);

    for hs = 1:2

        if hs == 1
            HsSufix = 'l';
            fprintf(' Left HS\n');
        else
            HsSufix = 'r';
            fprintf(' Right HS\n');
        end

        FeatureSaveFile = fullfile(DestDir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                             num2str(NbLayers) '_surf.mat']);

        vtk = spm_select('FPList', fullfile(SubDir, 'anat', 'cbs'), ...
                         ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex, inf_faces, ~] = read_vtk(vtk, 0, 1);

        NbVertices(hs) = size(inf_vertex, 2);

        Betas = dir(fullfile(DestDir, ['Beta*' HsSufix 'cr.vtk']));

        AllMapping = nan(NbVertices(hs), NbLayers, size(Betas, 1));

        fprintf(1, '   [%s]\n   [ ', repmat('.', 1, size(Betas, 1)));

        tic;

        parfor iBeta = 1:size(Betas, 1)

            A = fileread(fullfile(DestDir, Betas(iBeta).name)); % reads file quickly
            B = A(strfind(A, 'TABLE default') + 14:end); % clear A; % extracts lines that correspond to the mapping

            C = textscan(B, Spec, 'returnOnError', 0); % clear B; % extracts values from those lines
            Mapping = cell2mat(C); % clear C

            if size(Mapping, 1) ~= (NbVertices(hs)) %#ok<PFBNS>
                error('A VTK file has wrong number of vertices:\n%s', fullfile(DestDir, Betas(iBeta).name));
            end

            AllMapping(:, :, iBeta) = Mapping;

            fprintf(1, '\b.\n');

        end
        fprintf(1, '\b]\n');

        toc;

        A = AllMapping == 0;
        A = squeeze(any(A, 2));
        A = ~any(A, 2);
        VertexWithData = find(A);
        clear A;

        AllMapping = AllMapping(VertexWithData, :, :);

        fprintf('  Saving\n');
        save(FeatureSaveFile, 'inf_vertex', 'inf_faces', 'AllMapping', 'VertexWithData', '-v7.3');

        clear Betas Mapping A B C vtk AllMapping Face;

    end

end
