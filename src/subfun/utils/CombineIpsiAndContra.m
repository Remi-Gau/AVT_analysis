% (C) Copyright 2020 Remi Gau

function [Data, ConditionVec, RunVec] = CombineIpsiAndContra(Data, ConditionVec, RunVec, Type)
    %
    % Collapse across ipsi and contra stimuli by either pooling or averaging (mean)
    % features.
    %
    % USAGE::
    %
    %   [Data, ConditionVec, RunVec] = CombineIpsiAndContra(Data, ConditionVec, RunVec, Type)
    %
    % We loop over partitions and then for each condition (A, V, T)
    % we combine the ipsi and contra data of that partition.
    %

    if nargin < 4
        Type = 'pool';
    end

    Data_tmp = [];

    for iRun = 1:max(RunVec)

        ThisRun = RunVec == iRun;

        for iCdt = 1:2:max(ConditionVec)

            % Combine a row and the folowing one
            ConditionsToCombine = all([ThisRun, ismember(ConditionVec, iCdt:(iCdt + 1))], 2);

            switch lower(Type)
                case 'mean'
                    Data_tmp(end + 1, :) = mean(Data(ConditionsToCombine, :)); %#ok<*AGROW>

                case 'pool'
                    tmp = Data(ConditionsToCombine, :)';
                    tmp = tmp(:)'';
                    Data_tmp(end + 1, :) = tmp;

            end
        end
    end

    Data = Data_tmp;

    % Then we only keep the rows where the data has been combined
    ConditionVec(ismember(ConditionVec, 2:2:max(ConditionVec))) = 0;

    RunVec(ConditionVec == 0) = [];
    ConditionVec(ConditionVec == 0) = [];

    if any(isnan(Data(:)))
        error('We should not have any NaNs.');
    end

end
