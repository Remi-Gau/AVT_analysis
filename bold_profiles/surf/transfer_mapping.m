clc
clear
close all

StartDir = fullfile(pwd, '..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))
Get_dependencies('D:\Dropbox')

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);


Source_dir = 'D:\Dropbox\PhD\Experiments\AVT\derivatives\figures\surfaces\RH\Cdt';

for  iSub = 1:NbSub
    
    VTK_inf = spm_select('FPList', fullfile('E:\derivatives', SubLs(iSub).name, 'anat', 'cbs'), ...
        ['^' SubLs(iSub).name '.*_rcr_gm_avg_inf.vtk$']);

    Files2transfer = spm_select('FPList', Source_dir, ...
        ['^' SubLs(iSub).name '_rcr.*.vtk$']);

    
    [inf_vertex,inf_faces,~] = read_vtk(VTK_inf, 0, 1);
    
    for  iFile = 1:size(Files2transfer,1)
        
        Filename = deblank(Files2transfer(iFile,:));
        
        [inf_vertex_func,inf_faces_func,mapping] = read_vtk(Filename, 0, 1);
        
        write_vtk([Filename(1:end-4) '_remap.vtk'], inf_vertex, inf_faces, mapping)
    end
end