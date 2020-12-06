% (C) Copyright 2020 Remi Gau

clear
close all

Opt.NbSubject = 10;
Opt.NbRuns = 20;
Opt.NbLayers = 6;

Opt.IsMvpa = false;

Opt.ErrorBarType = 'STD';
Opt.Alpha = 0.05;
Opt.PlotPValue = true;
Opt.SideOfTtest = 'both';
Opt.PermutationTest.Do = true;

Opt.PlotSubjects = true;
Opt.ShadedErrorBar = true;
Opt.PlotQuadratic = true;


%% Plot one ROI / Condition
Cst = 1;
Lin = 0.5;
Quad = 0.1;

Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.2;
Opt.StdDevWithinSubject = 0.1;

Opt.Titles{1} = 'ROI 1 - Condition Name';

Opt.RoiNames = {'ROI 1'};

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

PlotProfileAndBetas(Data, SubjectVec, Opt)


%% Plot several ROIs

Opt.Titles{1,1} = 'Condition 1';

Opt.RoiNames = {'ROI 1', 'ROI 2'};

DataAllRois{1,1,1} = Data;
SubjectVecAllRois{1,1,1} = SubjectVec;

Cst = -2;
Lin = 0.8;
Quad = 0.1;

Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.8;
Opt.StdDevWithinSubject = 1;

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

DataAllRois{1,1,2} = Data;
SubjectVecAllRois{1,1,2} = SubjectVec;

PlotProfileAndBetas(DataAllRois, SubjectVecAllRois, Opt)


%% Plot several ROIs and several conditions

Opt.Titles{1,2} = 'Condition 2';

Opt.RoiNames = {'ROI 1', 'ROI 2'};

Cst = -2;
Lin = -0.8;
Quad = 0.1;

Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.8;
Opt.StdDevWithinSubject = 1;

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

DataAllRois{:,2,1} = Data;
SubjectVecAllRois{:,2,1} = SubjectVec;

Cst = 2;
Lin = -0.4;
Quad = 0.1;

Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.8;
Opt.StdDevWithinSubject = 1;

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

DataAllRois{:,2,2} = Data;
SubjectVecAllRois{:,2,2} = SubjectVec;


PlotProfileAndBetas(DataAllRois, SubjectVecAllRois, Opt)
