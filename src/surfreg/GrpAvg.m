clear;
clc;

hs = 'lr';

StartDir = fullfile(pwd, '..', '..');
cd(StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

% DataFolder = fullfile(StartDir, 'surfreg','GrpAvgBOLD');
DataFolder = fullfile(StartDir, 'surfreg', 'GrpAvgTargets');

NbLayers = 6;

% CondNames = {...
%     'AStimL','AStimR';...
%     'VStimL','VStimR';...
%     'TStimL','TStimR'};

CondNames = { ...
             'ATargL', 'ATargR'; ...
             'VTargL', 'VTargR'; ...
             'TTargL', 'TTargR'};

%%

for ihs = numel(hs)

    clear InfVertex InfFace Vertex Face Mapping AllLayersMask AllLayers;

    cd(fullfile(DataFolder, [upper(hs(ihs)) 'H']));

    InfSurfFile = fullfile(DataFolder, ['Surface_ls_low_res_' hs(ihs) 'h_inf.vtk']);
    [InfVertex, InfFace, ~] = read_vtk(InfSurfFile, 0, 1);
    SurfFile = fullfile(DataFolder, ['Surface_ls_low_res_' hs(ihs) 'h.vtk']);
    [Vertex, Face, ~] = read_vtk(InfSurfFile, 0, 1);

    for iCond = 1:numel(CondNames)

        parfor iLayer = 1:NbLayers

            VTK_file = dir(['GrpSurf_' CondNames{iCond} '_layer_' num2str(iLayer) '_' hs(ihs) 'h.vtk']); %#ok<*PFBNS>
            disp(VTK_file.name);

            [~, ~, Mapping] = read_vtk(VTK_file.name, 9, 1);

            Mask = logical(Mapping);
            AllLayersMask(iLayer, :) = sum(Mask); %#ok<*SAGROW>

            Mapping = mean(Mapping);
            AllLayers(iLayer, :) = Mapping;

        end

        write_vtk(['mean_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], Vertex, Face, AllLayers', 6);
        write_vtk(['mean_inf_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], InfVertex, InfFace, AllLayers', 6);

        write_vtk(['mask_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], Vertex, Face, AllLayersMask', 6);
        write_vtk(['mask_inf_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], InfVertex, InfFace, AllLayersMask', 6);

        write_vtk(['mask_bin_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], Vertex, Face, (AllLayersMask == 10)', 6);
        write_vtk(['mask_bin_inf_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], InfVertex, InfFace, (AllLayersMask == 10)', 6);

        AllLayers(AllLayersMask < 10) = 0;
        write_vtk(['mean_mask_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], Vertex, Face, AllLayers, 6);
        write_vtk(['mean_mask_inf_' CondNames{iCond} '_' hs(ihs) 'h.vtk'], InfVertex, InfFace, AllLayers, 6);

    end

end
