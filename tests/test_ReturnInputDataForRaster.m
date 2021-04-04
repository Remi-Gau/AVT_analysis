% (C) Copyright 2020 Remi Gau

function test_suite = test_ReturnInputDataForRaster %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ReturnInputDataForRasterBasic()

    NbConditions = 2;
    NbRuns = 3;
    NbLayers = 4;
    NbVertices = 5;

    [Data, ConditionVec, RunVec] = GenerateDummySurfaceRoiData(NbConditions, ...
                                                               NbRuns, ...
                                                               NbLayers, ...
                                                               NbVertices);

    ConditionToReturn = 2;

    RasterData = ReturnInputDataForRaster(Data, ConditionVec, RunVec, ConditionToReturn);

    assertEqual(size(RasterData), [NbVertices, NbLayers, NbRuns]);

end
