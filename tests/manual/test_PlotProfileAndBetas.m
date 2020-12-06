% (C) Copyright 2020 Remi Gau

clear
close all

Opt.NbSubject = 10;
Opt.NbRuns = 20;
Opt.NbLayers = 6;

Opt.IsMvpa = false;

Opt.ErrorBarType = 'STD';
Opt.Alpha = 0.05;

Opt.PlotSubjects = true;
Opt.ShadedErrorBar = true;
Opt.PlotQuadratic = false;

Opt.FigDim = [50, 50, 600, 600];

%     switch size(SubPlots, 2)
%         case 3
%             figdim = [50, 50, 1800, 800];
%         case 2
%             figdim = [50, 50, 1200, 600];
%         case 1
%             figdim = [50, 50, 600, 600];
%     end

%% Plot one ROI / Condition
Cst = 1;
Lin = 0.5;
Quad = 0.1;

Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.5;
Opt.StdDevWithinSubject = 1;

Opt.Titles{1} = 'ROI name - Condition Name';

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);
PlotProfileAndBetas(Data, SubjectVec, Opt)

%% Plot several ROIs

Opt.Titles{1} = 'Condition 1';

DataAllRois{1} = Data;
SubjectVecAllRois{1} = SubjectVec;

Cst = 2;
Lin = 0.8;
Quad = 0.1;

Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.8;
Opt.StdDevWithinSubject = 1;

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

DataAllRois{:,:,2} = Data;
SubjectVecAllRois{:,:,2} = SubjectVec;

PlotProfileAndBetas(DataAllRois, SubjectVecAllRois, Opt)
