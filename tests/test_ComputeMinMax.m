% (C) Copyright 2020 Remi Gau

function test_suite = test_ComputeMinMax %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ComputeMinMaxBasic()

    Opt.ErrorBarType = 'SEM';
    Opt.PlotSubjects = true();

    SubjectVec = [1 1 2 2 3 3];

    Data = [
            1 1  % subject 1
            1 1  % subject 1
            2 2  % subject 2
            1 1  % subject 2
            3 3  % subject 3
            2 2  % subject 3
           ];

    [Min, Max] = ComputeMinMax('all', Data, SubjectVec, Opt);

    assertEqual(Min, 0);
    assertEqual(Max, 2.5);

end

function test_ComputeMinMax2ROIs()

    Opt.ErrorBarType = 'SEM';
    Opt.PlotSubjects = true();

    SubjectVec{1, 1, 1} = [1 1 2 2 3 3];

    Data{1, 1, 1} = [
                     1 1  % subject 1
                     1 1  % subject 1
                     2 2  % subject 2
                     1 1  % subject 2
                     3 3  % subject 3
                     2 2  % subject 3
                    ];

    SubjectVec{1, 1, 2} = [1 1 2 2 3 3];

    Data{1, 1, 2} = [
                     -1 -1  % subject 1
                     -1 -1  % subject 1
                     2 2  % subject 2
                     1 1  % subject 2
                     3 3  % subject 3
                     2 2  % subject 3
                    ];

    [Min, Max] = ComputeMinMax('all', Data, SubjectVec, Opt);

    assertEqual(Min, -1);
    assertEqual(Max, 2.5);

end

function test_ComputeMinMax2ROIs2ConditionsGroup()

    Opt.ErrorBarType = 'SEM';
    Opt.PlotSubjects = true();

    for iLine = 1:2
        for iColumn = 1:2

            SubjectVec{1, iColumn, iLine} = [1 1 2 2 3 3];

            Data{1, iColumn, iLine} = [
                                       -2 -2  % subject 1
                                       -2 -2  % subject 1
                                       iColumn iColumn  % subject 2
                                       iColumn iColumn  % subject 2
                                       iLine iLine  % subject 3
                                       iLine iLine  % subject 3
                                      ];

        end
    end

    [Min, Max] = ComputeMinMax('groupallcolumns', Data, SubjectVec, Opt);

    assertEqual(Min, -1);
    assertEqual(Max, 2);

end

function test_ComputeMinMax2ROIs2ConditionsGroupColumn()

    Opt.ErrorBarType = 'SEM';
    Opt.PlotSubjects = true();
    ColumnToReport = 2;

    for iLine = 1:2
        for iColumn = 1:2

            SubjectVec{1, iColumn, iLine} = [1 1 2 2 3 3];

            Data{1, iColumn, iLine} = [
                                       -2 -2  % subject 1
                                       -2 -2  % subject 1
                                       iColumn iColumn  % subject 2
                                       iColumn iColumn  % subject 2
                                       iLine iLine  % subject 3
                                       iLine iLine  % subject 3
                                      ];

        end
    end

    [Min, Max] = ComputeMinMax('group', Data, SubjectVec, Opt, ColumnToReport);

    assertElementsAlmostEqual(Min, -0.86852, 'absolute', 5 * 1e-3);
    assertEqual(Max, 2);

end
