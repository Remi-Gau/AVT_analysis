% (C) Copyright 2021 Remi Gau

function test_suite = test_Deconvolution %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_MeanDeconvolution

    OptGenData.NbSubject = 1;
    OptGenData.NbRuns = 200;
    OptGenData.NbLayers = 6;
    
    ROI = 1;
    Cdt = 1;

    NbLayers = 6;

    Data =  GenerateDataROI(OptGenData, 1, 1);

    MeanData = mean(Data);

    DeconvolvedData = PerfomDeconvolution(Data, NbLayers);
    DeconvolvedMeanData = PerfomDeconvolution(MeanData, NbLayers);

    MeanDeconvolvedData = mean(DeconvolvedData);

    assertElementsAlmostEqual(DeconvolvedMeanData, MeanDeconvolvedData, 'absolute');

    % ans =
    %
    %    1.0e-15 *
    %
    %          0    0.0971    0.2220    0.2220   -0.3331    0.2776

end
