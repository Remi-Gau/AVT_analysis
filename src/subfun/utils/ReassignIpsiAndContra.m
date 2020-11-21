% (C) Copyright 2020 Remi Gau

function RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, Hemisphere, DoFeaturePooling)
    %
    % Swap left and right for the right hemisphere, so that we have everything
    % in terms of contra and ispi
    %
    % In practice this list of condition:
    %
    %     % CondNames = { ...
    %       'AStimL', 'AStimR', ...
    %       'VStimL', 'VStimR', ...
    %       'TStimL', 'TStimR', ...
    %       'ATargL', 'ATargR', ...
    %       'VTargL', 'VTargR', ...
    %       'TTargL', 'TTargR' ...
    %       };
    %
    % Becomes for both hempisphere
    %
    %     % CondNames = { ...
    %       'AStimIpsi', 'AStimContra', ...
    %       'VStimIpsi', 'VStimContra', ...
    %       'TStimIpsi', 'TStimContra', ...
    %       'ATargIpsi', 'ATargContra', ...
    %       'VTargIpsi', 'VTargContra', ...
    %       'TTargIpsi', 'TTargContra' ...
    %       };

    if nargin < 3
        error('minimum 3 arguments necessary: RoiData, ConditionVec, Hemisphere');
    end

    % Skip the left hemisphere
    if Hemisphere == 1 || strcmpi(Hemisphere, 'l') || strcmpi(Hemisphere, 'lh')
        return
    end

    if nargin < 4 || isempty(DoFeaturePooling)
        DoFeaturePooling = true;
    end

    if DoFeaturePooling

        tmp = nan(size(RoiData));

        for iCdt = 1:2:max(ConditionVec)
            tmp(ConditionVec == iCdt, :) = RoiData(ConditionVec == (iCdt + 1), :);
        end

        for iCdt = 2:2:max(ConditionVec)
            tmp(ConditionVec == iCdt, :) = RoiData(ConditionVec == (iCdt - 1), :);
        end

        RoiData = tmp;

    end

end
