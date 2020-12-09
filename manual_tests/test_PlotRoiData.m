%% (C) Copyright 2020 Remi Gau

clear
close all

NbVoxels = 100;
NbConditions = 12;
NbRuns = 20;

Data = randn(NbRuns * NbConditions, NbVoxels);

RunVec = repmat(1:NbRuns, NbConditions, 1);
RunVec = RunVec(:);

ConditionVec = repmat((1:NbConditions)', NbRuns, 1);

RunPerSes = ReturnNbRunsPerSession();

PlotRoiData(Data, ConditionVec, RunVec);



load('/home/remi/gin/AVT/derivatives/laminarGlm_space-surf_MVNN-0/sub-02/sub-02_hs-l_roi-A1_param-cst_nbLayers-6.mat')

PlotRoiData(RoiData, ConditionVec, RunVec);