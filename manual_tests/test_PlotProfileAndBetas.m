%% (C) Copyright 2020 Remi Gau

function test_suite = test_PlotProfileAndBetas %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function Opt = SetOptions(Opt, J)

    Opt.PlotQuadratic = false;
    Opt.ErrorBarType = 'STD';
    Opt.Alpha = 0.05;
    Opt.PlotPValue = true;
    Opt.PermutationTest.Do = true;
    Opt.PlotSubjects = true;
    Opt.ShadedErrorBar = true;
    Opt.NbLayers = 6;

    Opt.Specific{1, J}.PlotMinMaxType = 'groupallcolumns'; % all group groupallcolumns
    Opt.Specific{1, J}.IsMvpa = false;
    Opt.Specific{1, J}.Ttest.SideOfTtest = 'both';

end

function [Data, SubjectVec] = GenerateDataROI(OptGenData, ROI, Cdt)

    if ROI == 1 && Cdt == 1
        Cst = -2;
        Lin = 0.8;
        Quad = 0.1;
    end

    if ROI == 2 && Cdt == 1
        Cst = -2;
        Lin = 0.8;
        Quad = 0.1;
    end

    if ROI == 1 && Cdt == 2
        Cst = -2;
        Lin = -0.8;
        Quad = 0.1;
    end

    if ROI == 2 && Cdt == 2
        Cst = 2;
        Lin = -0.4;
        Quad = 0.1;
    end

    OptGenData.StdDevBetweenSubject = 1;
    OptGenData.StdDevWithinSubject = 1;

    OptGenData.Betas = [Cst; Lin; Quad];

    [Data, SubjectVec] = GenerateGroupDataLaminarProfiles(OptGenData);

end

function test_OneRoi

    close all;

    %% Plot one ROI / Condition

    OptGenData.NbSubject = 10;
    OptGenData.NbRuns = 20;
    OptGenData.NbLayers = 6;

    [Data, SubjectVec] = GenerateDataROI(OptGenData, 1, 1);
    Opt.Specific{1}.Data = Data;
    Opt.Specific{1}.SubjectVec = SubjectVec;
    Opt.Specific{1}.ConditionVec = ones(size(Data, 1), 1);
    Opt.Specific{1}.RoiVec = ones(size(Data, 1), 1);

    Opt.Specific{1}.Titles = 'ROI 1 - Condition Name';
    Opt.Specific{1}.RoiNames = 'ROI 1';

    Opt = SetOptions(Opt, 1);

    PlotProfileAndBetas(Opt);

end

function test_TwoRois

    OptGenData.NbSubject = 10;
    OptGenData.NbRuns = 20;
    OptGenData.NbLayers = 6;

    [Data1, SubjectVec1] =  GenerateDataROI(OptGenData, 1, 1);
    [Data2, SubjectVec2] =  GenerateDataROI(OptGenData, 1, 2);

    Data = cat(1, Data1, Data2);
    SubjectVec = cat(1, SubjectVec1, SubjectVec2);

    Opt.Specific{1}.Data = Data;
    Opt.Specific{1}.SubjectVec = SubjectVec;
    Opt.Specific{1}.ConditionVec = [ones(size(Data1, 1), 1); ones(size(Data2, 1), 1)];
    Opt.Specific{1}.RoiVec = [ones(size(Data1, 1), 1); 2 * ones(size(Data2, 1), 1)];

    Opt.Specific{1}.Titles = 'Condition 1';
    Opt.Specific{1}.RoiNames = {'ROI 1', 'ROI 2'};

    Opt = SetOptions(Opt, 1);

    PlotProfileAndBetas(Opt);

end

function test_TwoRoisSeveralConditions

    OptGenData.NbSubject = 10;
    OptGenData.NbRuns = 20;
    OptGenData.NbLayers = 6;

    iColumn = 1;

    Opt.Specific{1, iColumn}.Titles = 'Condition 1';
    Opt.Specific{1, iColumn}.RoiNames = {'ROI 1', 'ROI 2'};

    [Data1, SubjectVec1] =  GenerateDataROI(OptGenData, 1, 1);
    [Data2, SubjectVec2] =  GenerateDataROI(OptGenData, 1, 2);

    Data = cat(1, Data1, Data2);
    SubjectVec = cat(1, SubjectVec1, SubjectVec2);

    Opt.Specific{1, iColumn}.Data = Data;
    Opt.Specific{1, iColumn}.SubjectVec = SubjectVec;
    Opt.Specific{1, iColumn}.ConditionVec = [ones(size(Data1, 1), 1); ones(size(Data2, 1), 1)];
    Opt.Specific{1, iColumn}.RoiVec = [ones(size(Data1, 1), 1); 2 * ones(size(Data2, 1), 1)];

    %%
    iColumn = 2;

    Opt.Specific{1, iColumn}.Titles = 'Condition 2';
    Opt.Specific{1, iColumn}.RoiNames = {'ROI 1', 'ROI 2'};

    [Data1, SubjectVec1] =  GenerateDataROI(OptGenData, 2, 1);
    [Data2, SubjectVec2] =  GenerateDataROI(OptGenData, 2, 2);

    Data = cat(1, Data1, Data2);
    SubjectVec = cat(1, SubjectVec1, SubjectVec2);

    Opt.Specific{1, iColumn}.Data = Data;
    Opt.Specific{1, iColumn}.SubjectVec = SubjectVec;
    Opt.Specific{1, iColumn}.ConditionVec = [2 * ones(size(Data1, 1), 1); 2 * ones(size(Data2, 1), 1)];
    Opt.Specific{1, iColumn}.RoiVec = [ones(size(Data1, 1), 1); 2 * ones(size(Data2, 1), 1)];

    Opt = SetOptions(Opt, 1);
    Opt = SetOptions(Opt, 2);

    PlotProfileAndBetas(Opt);

end
