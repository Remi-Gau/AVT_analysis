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

  clear InfVertex InfFace Vertex Face Mapping AllLayersMask AllLayers;

  cd(fullfile(DataFolder));

  InfSurfFile = fullfile(DataFolder, ['Surface_ls_low_res_' hs(ihs) 'h_inf.vtk']);
  [InfVertex, InfFace, ~] = read_vtk(InfSurfFile, 0, 1);
  SurfFile = fullfile(DataFolder, ['Surface_ls_low_res_' hs(ihs) 'h.vtk']);
  [Vertex, Face, ~] = read_vtk(InfSurfFile, 0, 1);

  for iROI = 1:numel(ROIs)

    VTK_file = dir(['GrpSurf_' ROIs{iROI} '_' hs(ihs) 'h.vtk']); %#ok<*PFBNS>
    disp(VTK_file.name);

    [~, ~, Mapping] = read_vtk(VTK_file.name, 9, 1);

    if iROI < numel(ROIs)
      Mapping(Mapping < 0) = 0;
      Mapping(Mapping < 40) = 0;
      Mapping(Mapping > 0) = 1;
    else
      Mapping(Mapping > 0) = 1;
    end

    Mapping = mean(Mapping);

    write_vtk(['mean_' ROIs{iROI} '_' hs(ihs) 'h.vtk'], Vertex, Face, Mapping', 1);
    write_vtk(['mean_inf_' ROIs{iROI} '_' hs(ihs) 'h.vtk'], InfVertex, InfFace, Mapping', 1);
  end

end
