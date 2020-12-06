% (C) Copyright 2020 Remi Gau

clear
close all

Cst = 1;
Lin = 0.5;
Quad = 0.1;

Opt.NbSubject = 10;
Opt.NbRuns = 20;
Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.5;
Opt.StdDevWithinSubject = 1;
Opt.NbLayers = 6;

Opt.Fontsize = 8;
Opt.IsMvpa = false;
Opt.PlotSubjects = true;
Opt.PlotQuadratic = false;
Opt.ErrorBar = 'CI-BC';
Opt.Visible = 'on';
Opt.ShadedErrorBar = false;
Opt.FigDim = [50, 50, 600, 600];
Opt.Alpha = 0.05;

%     switch size(SubPlots, 2)
%         case 3
%             figdim = [50, 50, 1800, 800];
%         case 2
%             figdim = [50, 50, 1200, 600];
%         case 1
%             figdim = [50, 50, 600, 600];
%     end


[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

PlotProfileAndBetas(Data, SubjectVec, Opt)

