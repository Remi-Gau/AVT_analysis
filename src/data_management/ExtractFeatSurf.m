% reads from VTK file containing the beta values mapped to surfaces
% and saves their content to a BIG mat file
%
% Only keeps the vertices with data: their indices is kept in the VertexWithData
% variable

% OUTPUT
%
% fullfile(OuputDir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' NbLayers '_surf.mat]')
%
% - VertexWithData
% - AllMapping  with dimensions [NbVertices(hs), NbLayers, size(Betas, 1)];
% - inf_vertex: vertices from the surface. see read_vtk
% - inf_faces: faces from the surface. see read_vtk
%
% The last 2 are kept in cases surface needs to be reconstructed

clc;
clear;

MVNN = false;
TARGET = false;

%%
NbLayers = 6;

[Dirs] = set_dir('surf');

[SubLs, NbSub] = get_subject_list(Dirs.ExternalHD);

pipeline = 'extract-vtk_MVNN-0';
if MVNN
  pipeline = 'extract-vtk_MVNN-1';
end

for iSub = 1 % NbSub

  fprintf('Processing %s\n', SubLs(iSub).name);

  % Directories
  OuputDir = fullfile(Dirs.DerDir, pipeline, SubLs(iSub).name);

  SubDir = fullfile(Dirs.ExternalHD, SubLs(iSub).name);

  InputDir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf');
  if MVNN
    InputDir = fullfile(SubDir, 'ffx_rsa', 'betas', '6_surf');
  end

  %% Load data or extract them

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

    vtk = spm_select('FPList', fullfile(SubDir, 'anat', 'cbs'), ...
                     ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
    [inf_vertex, inf_faces, ~] = read_vtk(vtk, 0, 1);

    NbVertices(hs) = size(inf_vertex, 2);

    Betas = spm_select('FPList', InputDir, ['^Beta.*' HsSufix 'cr.vtk$']);

    AllMapping = nan(NbVertices(hs), NbLayers, size(Betas, 1));

    fprintf(1, '   [%s]\n   [ ', repmat('.', 1, size(Betas, 1)));

    tic;

    parfor iBeta = 1:size(Betas, 1)

      % reads file quickly
      A = fileread(Betas(iBeta, :));

      % extracts lines that correspond to the mapping
      B = A(strfind(A, 'TABLE default') + 14:end);

      % extracts values from those lines
      C = textscan(B, Spec, 'returnOnError', 0);
      Mapping = cell2mat(C); % clear C

      if size(Mapping, 1) ~= (NbVertices(hs)) %#ok<PFBNS>
        error('A VTK file has wrong number of vertices:\n%s', ...
              Betas(iBeta, :));
      end

      % vertices * layers * beta images
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

    %%
    fprintf('  Saving\n');
    [~, ~, ~] = mkdir(OuputDir);
    FeatureSaveFile = fullfile(OuputDir, [ ...
                                          SubLs(iSub).name  '_features_' ...
                                          HsSufix 'hs_' ...
                                          num2str(NbLayers) '_surf.mat' ...
                                         ]);

    save(FeatureSaveFile, ...
         'inf_vertex', 'inf_faces', 'AllMapping', 'VertexWithData', ...
         '-v7.3');

    clear Betas Mapping A B C vtk AllMapping Face;

  end

end
