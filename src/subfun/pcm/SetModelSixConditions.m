% (C) Copyright 2021 Remi Gau

function M = SetModelSixConditions(M, ConditionScaled, IpsiContraScaled)
    %
    % Set up PCM models with A, V and T conditions, with ipsi and contra
    % stimulations
    %
    % USAGE::
    %
    %   M = templateFunction(M, ConditionScaled, IpsiContraScaled)
    %
    % :param M: Models: the function will create `M{end}.Ac`
    % :type M: cell
    % :param ConditionScaled: ``{[conditions scaled to each other], [indendent conditions]}``
    %                         For example: ``{[VT], [A]}``
    % :type ConditionScaled: cell
    % :param IpsiContraScaled: Vector to denote whether ipsi and contra of a
    %                          certain condition are scaled to each other. In
    %                          the order AVT. For example: ``[true(), false(), false()]``
    % :type IpsiContraScaled: logical vector

    M{end + 1}.Ac = [];

    %%
    % all scaled
    ColumnAudioIpsi = 1;
    ColumnVisualIpsi = 1;
    ColumnTactileIpsi = 1;

    if strcmp(ConditionScaled{1}, 'VT') && strcmp(ConditionScaled{2}, 'A')
        ColumnAudioIpsi = 1;
        ColumnVisualIpsi = 3;
        ColumnTactileIpsi = 3;
    end

    if strcmp(ConditionScaled{1}, 'AT') && strcmp(ConditionScaled{2}, 'V')
        ColumnAudioIpsi = 3;
        ColumnVisualIpsi = 1;
        ColumnTactileIpsi = 3;
    end

    % all indepentent
    if strcmp(ConditionScaled{2}, 'AVT')
        ColumnAudioIpsi = 1;
        ColumnVisualIpsi = 3;
        ColumnTactileIpsi = 5;
    end

    %%
    if IpsiContraScaled(1)
        ColumnAudioContra = ColumnAudioIpsi;
    else
        ColumnAudioContra = ColumnAudioIpsi + 1;
    end

    if IpsiContraScaled(2)
        ColumnVisualContra = ColumnVisualIpsi;
    else
        ColumnVisualContra = ColumnVisualIpsi + 1;
    end

    if IpsiContraScaled(3)
        ColumnTactileContra = ColumnTactileIpsi;
    else
        ColumnTactileContra = ColumnTactileIpsi + 1;
    end

    %%
    ColToAdd = [ ...
                ColumnAudioIpsi, ColumnAudioContra, ...
                ColumnVisualIpsi, ColumnVisualContra, ...
                ColumnTactileIpsi, ColumnTactileContra];
    RowToAdd = [1, 2, 3, 4, 5, 6];

    for iCdt = 1:numel(RowToAdd)
        M = SetFeatureThisCondition(M, ColToAdd(iCdt), RowToAdd(iCdt));
    end

    %% remove any empty columns
    IsEmptyColumn = M{end}.Ac == 0;
    IsEmptyColumn = all(all(IsEmptyColumn, 1), 3);
    M{end}.Ac(:, IsEmptyColumn, :) = [];

    %% remove any empty feature
    IsEmptyFeature = M{end}.Ac == 0;
    IsEmptyFeature = all(all(IsEmptyFeature, 1), 2);
    M{end}.Ac(:, :, IsEmptyFeature) = [];
end
