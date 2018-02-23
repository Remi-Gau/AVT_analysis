clc; clear; close all

StartFolder=fullfile(pwd, '..','..');
addpath(genpath(fullfile(StartFolder, 'SubFun')))

SubjToInclude = true(13,1);
SubjToInclude([4 11],1) = false;

I = [1 2 10 15]; 
ROI_name = {'A1' 'PT' 'V1' 'V2-3'};


hs = 'r';
inf_hs = 'l';

InfSurfFile = fullfile(['/home/rxg243/Documents/GrpAverage/BoldAvg/Surface_ls_' inf_hs 'h_inf.vtk']);
[InfVertex,InfFace,InfMapping] = read_vtk(InfSurfFile, 0, 1);

cd('/home/rxg243/Documents/GrpAverage/ROI')

ROI_SurfFile = ['Surface_ls_' hs 'h_trgsurf_groupdata.vtk']; 
[Vertex,Face,Mapping] = read_vtk(ROI_SurfFile, 12, 1);

Mapping = Mapping(SubjToInclude,:);

Mapping = ceil(Mapping);

for i = 1:4
    tmp = zeros(size(Mapping));
    tmp(Mapping==I(i)) = 1;
    tmp = nansum(tmp);
    write_vtk([ROI_name{i} '_' hs 'h.vtk'], Vertex, Face, tmp')
    write_vtk([ROI_name{i} '_' hs 'h_inf.vtk'], InfVertex, InfFace, tmp')
    
    write_vtk([ROI_name{i} '_' hs 'h_thres.vtk'], Vertex, Face, (tmp>4)')
    write_vtk([ROI_name{i} '_' hs 'h_inf_thres.vtk'], InfVertex, InfFace, (tmp>4)')
end

% 
% mapping(ROI(1).VertOfInt{hs})=1;
%         mapping(ROI(2).VertOfInt{hs})=2;
%         mapping(ROI(3).VertOfInt{hs})=10;
%         mapping(ROI(4).VertOfInt{hs})=15;