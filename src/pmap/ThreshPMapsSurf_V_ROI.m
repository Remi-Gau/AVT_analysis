%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

ROIs = { ...
        'V1_Pmap_Ret'; ...
        'V2_Pmap_Ret'; ...
        'V3_Pmap_Ret'; ...
        'V4_Pmap_Ret'; ...
        'V5_Pmap_Ret'};

Thresh = 10;

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
    for iROI = 1:size(ROIs, 1)

      File = spm_select('FPList', fullfile(SubDir, 'pmap'), ...
                        ['^' SubLs(iSub).name '.*' suffix 'cr_gm_avg_' ROIs{iROI} '.vtk$']);

      [vertex, face, Mapping(iROI, :)] = read_vtk(File, 0, 1);

    end

    for iROI = 1:size(ROIs, 1)

      Include = false(1, size(ROIs, 1));
      Include(iROI) = true;

      for iThres = 1:numel(Thresh)
        tmp = zeros(1, size(Mapping, 2));

        tmp(1, Mapping(Include, :) > Thresh(iThres)) = 1;
        tmp(1, sum(Mapping(~Include, :)) > Mapping(Include, :)) = 0;

        write_vtk(fullfile(SubDir, 'pmap', [SubLs(iSub).name '_' suffix 'cr_' ROIs{iROI} '_thres_' num2str(Thresh(iThres)) '.vtk']), ...
                  vertex, face, tmp);
        write_vtk(fullfile(SubDir, 'pmap', [SubLs(iSub).name '_' suffix 'cr_' ROIs{iROI} '_thres_' num2str(Thresh(iThres)) '_inf.vtk']), ...
                  inf_vertex, inf_face, tmp);
      end
    end

    clear inf_vertex vertex inf_face face Mapping;

  end

end

cd(StartDir);
