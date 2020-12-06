% (C) Copyright 2020 Remi Gau

function [Min, Max] = ComputeMinMax(Data, SubjectVec, Opt, iCondtion)

    if nargin < 4
        iCondtion = 1;
    end

    Min = 0;
    Max = 0;

    for iLine = 1:size(Data, 3)

        GroupData = ComputeSubjectAverage( ...
                                          Data{:, iCondtion, iLine}, ...
                                          SubjectVec{:, iCondtion, iLine});

        if Opt.PlotSubjects
            ThisMax = max(GroupData(:));
            ThisMin = min(GroupData(:));

        else
            GroupMean =  mean(GroupData);
            [LowerError, UpperError] = ComputeDispersionIndex(GroupData, Opt);

            ThisMax = max(GroupMean(:) + UpperError(:));
            ThisMin = min(GroupMean(:) - LowerError(:));

        end

        Max = max([Max, ThisMax]);
        Min = min([Min, ThisMin]);

    end

end
