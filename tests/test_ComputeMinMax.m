% (C) Copyright 2020 Remi Gau

function test_suite = test_ComputeMinMax %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ComputeMinMaxBasic()

    Opt.tmp = '';

    Data = [
            1 1
            1 1
            2 2
            1 1
            3 3
            2 2
           ];

    [Min, Max] = ComputeMinMax('all', Data, Opt);

    assertEqual(Min, 0);
    assertEqual(Max, 3);

end

function test_ComputeMinMaxBasic2()

    Opt.tmp = '';

    Data{1, 1} = [
                  1 1
                  3 3
                  2 2
                 ];
    Data{1, 2} = [
                  1 1 0
                  -3 3 2
                 ];

    [Min, Max] = ComputeMinMax('all', Data, Opt);

    assertEqual(Min, -3);
    assertEqual(Max, 3);

end

function test_ComputeMinMaxBasic3()

    Opt.m = 2;

    Data(1, 1).Data = [
                       1 1
                       3 3
                       2 2
                      ];
    Data(1, 2).Data = [
                       1 1 0
                       -3 3 2
                      ];

    [Min, Max] = ComputeMinMax('all', Data, Opt);

    assertEqual(Min, -3);
    assertEqual(Max, 3);

end

function test_ComputeMinMaxGrouLevelAllGroups()

    Opt.m = 2;

    Data(1, 1).Mean = [
                       1 1
                       3 3
                       2 2
                      ];
    Data(1, 1).UpperError = [
                             1 1
                             3 3
                             2 2
                            ];
    Data(1, 1).LowerError = [
                             1 1
                             3 3
                             2 2
                            ];

    Data(1, 2).Mean = [
                       1 1 0
                       -3 3 2
                      ];
    Data(1, 2).UpperError = [
                             1 1 1
                             3 3 2
                            ];
    Data(1, 2).LowerError = [
                             1 1 0
                             3 3 2
                            ];

    [Min, Max] = ComputeMinMax('groupallcolumns', Data, Opt);

    assertEqual(Min, -6);
    assertEqual(Max, 6);

end

function test_ComputeMinMax2ROIs2ConditionsGroupColumn()

    Opt.m = 2;

    Data(1, 1).Mean = [
                       -5 0
                       -5 0
                       -3 0
                      ];
    Data(1, 1).UpperError = [
                             1 1
                             3 3
                             2 2
                            ];
    Data(1, 1).LowerError = [
                             1 1
                             3 3
                             2 2
                            ];

    Data(1, 2).Mean = [
                       1 1 0
                       -3 3 2
                      ];
    Data(1, 2).UpperError = [
                             1 1 1
                             3 3 2
                            ];
    Data(1, 2).LowerError = [
                             1 1 0
                             3 3 2
                            ];

    ColumnToReport = 1;
    [Min, Max] = ComputeMinMax('group', Data, Opt, ColumnToReport);

    assertEqual(Min, -8);
    assertEqual(Max, 3);

    ColumnToReport = 2;
    [Min, Max] = ComputeMinMax('group', Data, Opt, ColumnToReport);

    assertEqual(Min, -6);
    assertEqual(Max, 6);

end

function test_ComputeMinMax2ROIs2ConditionsGroupColumnParameter()

    Opt.m = 2;
    ColumnToReport = 2;
    Parameter = 2;

    Data(1, 1).Mean = [
                       0 0
                       0 0
                       0 0
                      ];
    Data(1, 1).UpperError = [
                             1 1
                             3 3
                             2 2
                            ];
    Data(1, 1).LowerError = [
                             1 1
                             3 3
                             2 2
                            ];

    Data(1, 2).Mean = [
                       0 -3
                       0 3
                      ];
    Data(1, 2).UpperError = [
                             1 1
                             3 3
                            ];
    Data(1, 2).LowerError = [
                             1 3
                             3 3
                            ];

    [Min, Max] = ComputeMinMax('group', Data, Opt, ColumnToReport, Parameter);

    assertEqual(Min, -6);
    assertEqual(Max, 6);

end
