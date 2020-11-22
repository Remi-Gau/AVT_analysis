% (C) Copyright 2020 Remi Gau

function test_suite = test_LineariseLaminarData %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_templateTestBasic()

    NbConditions = 2;
    NbRuns = 2;
    NbLayers = 3;
    NbVertices = 4;

    LayerVec = repmat([1:NbLayers]', NbConditions * NbRuns, 1);

    Data = repmat([1:NbLayers]', NbConditions * NbRuns, NbVertices);

    RunVec = [ ...
              ones(NbLayers * NbConditions, 1); ...
              2 * ones(NbLayers * NbConditions, 1)];

    ConditionVec = repmat([ones(NbLayers, 1); 2 * ones(NbLayers, 1)], NbRuns, 1);

    CvMat = [ConditionVec RunVec LayerVec];

    [Data, CvMat] = LineariseLaminarData(Data, CvMat);

    ExpectedRunVec = [ ...
                      ones(NbConditions, 1); ...
                      2 * ones(NbConditions, 1)];

    ExpectedConditionVec = repmat([1; 2], NbRuns, 1);

    assertEqual(Data, repmat([1:NbLayers], NbConditions * NbRuns, NbVertices));
    assertEqual(CvMat, [ExpectedConditionVec, ExpectedRunVec]);

end
