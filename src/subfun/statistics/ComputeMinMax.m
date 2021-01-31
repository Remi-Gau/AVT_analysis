% (C) Copyright 2020 Remi Gau

function [Min, Max] = ComputeMinMax(Type, Data, Opt, ColumnToReport)

    Min = 0;
    Max = 0;

    if isstruct(Data)
        [Data, Data2] = PrepareData(Type, Data, Opt);

    elseif ~iscell(Data)
        Data = {Data};

    end

    if strcmpi(Type, 'all')

        AllMax = cellfun(@(x) max(x), Data, 'UniformOutput', false);
        AllMin = cellfun(@(x) min(x), Data, 'UniformOutput', false);

        ThisMax = max(squeeze(cellfun(@(x) max(x), AllMax)));
        ThisMin = min(squeeze(cellfun(@(x) min(x), AllMin)));

        Max = max([Max, ThisMax]);
        Min = min([Min, ThisMin]);

        return

    end

    switch lower(Type)

        % get the min and max at the group level across conditions and ROIs
        case 'groupallcolumns'

            [~, ThisMax] = ComputeMinMax('all', Data, Opt);
            ThisMin = ComputeMinMax('all', Data2, Opt);

        case 'group'

            [~, ThisMax] = ComputeMinMax('all', Data{ColumnToReport}, Opt);
            ThisMin = ComputeMinMax('all', Data2{ColumnToReport}, Opt);

        otherwise
            error('Not sure what to do. Allowed Types are: all, group, groupallcolumns');

    end

    Max = max([Max, ThisMax]);
    Min = min([Min, ThisMin]);

end

function [Data1, Data2] = PrepareData(Type, Data, Opt)

    Data1 = {};
    Data2 = {};

    for i = 1:Opt.m

        if strcmpi(Type, 'all')
            Data1{1, i} = Data(1, i).Data; %#ok<*AGROW>

        else
            Data1{1, i} = Data(1, i).Mean + Data(1, i).UpperError;
            Data2{1, i} = Data(1, i).Mean - Data(1, i).LowerError;

        end

    end

end
