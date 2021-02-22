% (C) Copyright 2020 Remi Gau

function test_suite = test_GenerateGroupDataLaminarProfiles %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_GenerateGroupDataLaminarProfilesBasic

    Cst = 1;
    Lin = 0.5;
    Quad = 0.1;

    Opt.NbSubject = 2;
    Opt.NbRuns = 4;
    Opt.Betas = [Cst; Lin; Quad];
    Opt.StdDevBetweenSubject = 0;
    Opt.StdDevWithinSubject = 0;
    Opt.NbLayers = 6;

    [Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);

    BetaHat = RunLaminarGlm(Data);

    [GroupData] = ComputeSubjectAverage(Data, SubjectVec);
    [GroupDetaHatData, SubjectVec] = ComputeSubjectAverage(BetaHat, SubjectVec);

end
