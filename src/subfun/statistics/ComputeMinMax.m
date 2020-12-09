% (C) Copyright 2020 Remi Gau

function [Min, Max] = ComputeMinMax(Type, Data, SubjectVec, Opt, iColumn)

    if nargin < 5 || isempty(iColumn)
        iColumn = 1;
    end

    if ~iscell(Data)
        Data = {Data};
    end

    if ~iscell(SubjectVec)
        SubjectVec = {SubjectVec};
    end

    Min = 0;
    Max = 0;

    GroupData = cell(size(Data));
    %% get subject average for each parts of the cell
    for iCondtion = 1:size(Data, 2)
        for iLine = 1:size(Data, 3)

            GroupData{:, iCondtion, iLine} = ComputeSubjectAverage( ...
                                                                   Data{:, iCondtion, iLine}, ...
                                                                   SubjectVec{:, iCondtion, iLine}); %#ok<*AGROW>

        end
    end

    if strcmpi(Type, 'all')

        AllMax = cellfun(@(x) max(x), GroupData, 'UniformOutput', false);
        AllMin = cellfun(@(x) min(x), GroupData, 'UniformOutput', false);

        ThisMax = max(squeeze(cellfun(@(x) max(x), AllMax)));
        ThisMin = min(squeeze(cellfun(@(x) min(x), AllMin)));

        Max = max([Max, ThisMax]);
        Min = min([Min, ThisMin]);

        return

    end

    %% get subject average for each parts of the cell
    for iCondtion = 1:size(Data, 2)
        for iLine = 1:size(Data, 3)

            % this will only be necessary for group level stuff
            GroupMean =  mean(GroupData{:, iCondtion, iLine});
            [LowerError, UpperError] = ComputeDispersionIndex(GroupData{:, iCondtion, iLine}, Opt);

            GroupMax(:, iCondtion, iLine) = max(GroupMean(:) + UpperError(:));
            GroupMin(:, iCondtion, iLine) = min(GroupMean(:) - LowerError(:));

        end
    end

    switch lower(Type)

        % get the min and max at the group level across conditions and ROIs
        case 'groupallcolumns'

            ThisMax = max(GroupMax(:));
            ThisMin = min(GroupMin(:));

        case 'group'

            ThisMax = max(GroupMax(:, iColumn, :));
            ThisMin = min(GroupMin(:, iColumn, :));

        otherwise
            error('Not sure what to do. Allowed Types are: all, group, groupallcolumns');

    end

    Max = max([Max, ThisMax]);
    Min = min([Min, ThisMin]);

end
