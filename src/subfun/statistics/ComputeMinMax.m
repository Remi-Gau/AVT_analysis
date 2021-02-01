% (C) Copyright 2020 Remi Gau

function [Min, Max] = ComputeMinMax(Type, Data, Opt, ColumnToReport, Parameter)
    % gets minimum and maximum of
    % - an array
    % OR
    % - a horizontal cell of arrays
    % OR
    % on a horizontal structure of the shape:
    % - Struct(1,n).Data
    % OR
    % on a horizontal structure of the shape:
    % - Struct(1,n).Mean
    % - Struct(1,n).UpperError
    % - Struct(1,n).LowerError
    %
    % Type:
    % 'all' returns min and max of all values across arrays, cells, structures
    % 'groupallcolumns' returns min and max of all values across arrays, cells, structures for
    % the range [Struct(1,n).Mean-Struct(1,n).LowerError  Struct(1,n).Mean+Struct(1,n).UpperError]
    % 'group' returns min and max of the ColumnToReport cells, structures for
    % the range
    % [Struct(1,ColumnToReport).Mean-Struct(1,ColumnToReport).LowerError  ...
    %  Struct(1,ColumnToReport).Mean+Struct(1,ColumnToReport).UpperError]

    if nargin < 5
        Parameter = [];
    end

    Min = 0;
    Max = 0;

    if isstruct(Data)
        [Data, Data2] = PrepareData(Type, Data, Opt, Parameter);

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

function [Data1, Data2] = PrepareData(Type, Data, Opt, Parameter)

    Data1 = {};
    Data2 = {};

    for i = 1:Opt.m

        if strcmpi(Type, 'all')
            Data1{1, i} = FilterOnParameter(Data(1, i).Data, Parameter); %#ok<*AGROW>

        else
            tmp = Data(1, i).Mean + Data(1, i).UpperError;
            Data1{1, i} = FilterOnParameter(tmp, Parameter);
            tmp = Data(1, i).Mean - Data(1, i).LowerError;
            Data2{1, i} = FilterOnParameter(tmp, Parameter);

        end

    end

end

function Data = FilterOnParameter(Data, Parameter)
    if ~isempty(Parameter)
        Data = Data(:, Parameter);
    end
end
