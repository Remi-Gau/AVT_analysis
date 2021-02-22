% (C) Copyright 2020 Remi Gau

function test_suite = test_ComputeSubjectAverage %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ComputeSubjectAverageBasic()

    SubjectVec = [1 1 2 2];

    Data = [
            1 1  % subject 1
            1 1  % subject 1
            2 2  % subject 2
            1 1  % subject 2
            3 3  % subject 3
            2 2  % subject 3
           ];

    [GroupData, SubjectVec] = ComputeSubjectAverage(Data, SubjectVec);

    assertEqual(GroupData, [1, 1; 1.5, 1.5]);
    assertEqual(SubjectVec, [1; 2]);

end
