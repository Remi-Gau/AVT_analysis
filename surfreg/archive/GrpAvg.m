clear; clc

HS = 'L';
hs = 'l';
inf_hs = 'r';

StartFolder = fullfile(pwd, '..', '..');
cd(StartFolder)
addpath(genpath(fullfile(StartFolder, 'SubFun')));

DataFolder = fullfile('/home/rxg243/Documents/GrpAverage/BoldAvg');

InfSurfFile = fullfile(DataFolder, ['Surface_ls_' inf_hs 'h_inf.vtk']);
[InfVertex,InfFace,~] = read_vtk(InfSurfFile, 0, 1);


%%
cd(fullfile(DataFolder, [HS 'H'], 'exp-0000'))

FoldersList = dir('*.input');

for iFile = 1:numel(FoldersList)
    
    clear Content pat Stim Att Layer
    
    cd(FoldersList(iFile).name(1:end-6))
    disp(FoldersList(iFile).name(1:end-6))
    
    tmp = dir('SurfaceMeshGroupData');
    
    if ~isempty(tmp)
        
        Content = fileread('SurfaceMeshGroupData.input');
        
        pat = 'n\w*_Stim';
        Stim = regexp(Content, pat, 'match');
        Stim = Stim{1}(3:end-5);
        
        pat = '_\w*_Att';
        Att = regexp(Content, pat, 'match');
        Att = Att{1}(2:end-4);
        
        pat = 'iles_\d_c';
        Layer = regexp(Content, pat, 'match');
        Layer = Layer{1}(6);
        
        disp([Stim '-Stim_' Att '-Attention_' Layer '-Layer'])
        
        if Inter
            SurfFile = spm_select('FPList', fullfile(pwd, 'SurfaceMeshGroupData'), ...
                ['^T1_16_.*' hs 'h_crop_clone_transform_.*_avgsurf_groupdata.vtk$']);
        else
            SurfFile = spm_select('FPList', fullfile(pwd, 'SurfaceMeshGroupData'), ...
                ['^Surface_ls_' hs 'h_trgsurf_groupdata.vtk$']);
        end 
        copyfile(SurfFile, fullfile(DataFolder,  [HS 'H'], ...
            ['GrpSurf_' Stim '-Stim_' Att '-Attention_' Layer '-Layer_' hs 'h.vtk']))
        
        clear SurfFile
    end
    
    cd ..
end


%%
cd(fullfile(DataFolder, [HS 'H']))

NbLayers = 6;

Conditions_Names = {...
    'A-Stim_Auditory-Attention', ...
    'V-Stim_Auditory-Attention', ...
    'AV-Stim_Auditory-Attention', ...
    'A-Stim_Visual-Attention', ...
    'V-Stim_Visual-Attention', ...
    'AV-Stim_Visual-Attention'};

for iCond = 1:6
    
    
    
    for iLayer = 1:NbLayers
        
        VTK_file = dir(['GrpSurf_' Conditions_Names{iCond} '_' num2str(iLayer) '-Layer_' hs 'h.vtk']);
        
        disp(VTK_file.name)
        
        [Vertex,Face,Mapping] = read_vtk(VTK_file.name, 12, 1);

        Mask = logical(Mapping);
        AllLayersMask(iLayer,:) = sum(Mask); %#ok<*SAGROW>
        
        Mapping = mean(Mapping);
        AllLayers(iLayer,:) = Mapping;
        
    end

    write_vtk(['mean_' Conditions_Names{iCond} '_' hs 'h.vtk'], Vertex, Face, AllLayers', 6)
    write_vtk(['mean_inf_' Conditions_Names{iCond} '_' hs 'h.vtk'], InfVertex, InfFace, AllLayers', 6)

    write_vtk(['mask_' Conditions_Names{iCond} '_' hs 'h.vtk'], Vertex, Face, AllLayersMask', 6)
    write_vtk(['mask_inf_' Conditions_Names{iCond} '_' hs 'h.vtk'], InfVertex, InfFace, AllLayersMask', 6)
   
    write_vtk(['mask_bin_' Conditions_Names{iCond} '_' hs 'h.vtk'], Vertex, Face, (AllLayersMask==13)', 6)
    write_vtk(['mask_bin_inf_' Conditions_Names{iCond} '_' hs 'h.vtk'], InfVertex, InfFace, (AllLayersMask==13)', 6)

    AllLayers(AllLayersMask<13)=0;
    write_vtk(['mean_mask_' Conditions_Names{iCond} '_' hs 'h.vtk'], Vertex, Face, AllLayers, 6)
    write_vtk(['mean_mask_inf_' Conditions_Names{iCond} '_' hs 'h.vtk'], InfVertex, InfFace, AllLayers, 6)
    
end




