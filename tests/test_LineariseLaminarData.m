% (C) Copyright 2020 Remi Gau

function test_suite = test_LineariseLaminarData %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_LineariseLaminarDataBasic()
    
    NbConditions = 2;
    NbRuns = 3;
    NbLayers = 4;
    NbVertices = 5;

    [Data, ConditionVec, RunVec, LayerVec] = GenerateDummySurfaceRoiData(NbConditions, ...
        NbRuns, ...
        NbLayers, ...
        NbVertices);

    CvMat = [ConditionVec RunVec LayerVec];

    [Data, CvMat] = LineariseLaminarData(Data, CvMat);

    ExpectedRunVec = [];
    for i=1:NbRuns
        ExpectedRunVec = [ExpectedRunVec; i * ones(NbConditions, 1)];
    end

    ExpectedConditionVec = repmat([1; 2], NbRuns, 1);

    assertEqual(Data, repmat([1:NbLayers], NbConditions * NbRuns, NbVertices));
    assertEqual(CvMat, [ExpectedConditionVec, ExpectedRunVec]);

end
