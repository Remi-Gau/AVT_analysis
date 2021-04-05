% (C) Copyright 2021 Remi Gau

function [Data, CondNamesIpsiContra] = LoadProfileData(Opt, ROIs, InputDir) %#ok<STOUT>
    %
    % loops through the ROIs to load the data
    % reassigns lef tand right to ipsi and contra is necessary
    % reoranize output in a structure
    %
    
    for iROI =  1:numel(ROIs)

        Filename = ['Group-roi-', ROIs{iROI}, ...
                    '_average-', Opt.AverageType, ...
                    '_nbLayers-', num2str(Opt.NbLayers), '.mat' ...
                   ];

        load(fullfile(InputDir, Filename));

        if Opt.PoolIpsiContra

            % We remove nans and then average ipsi and contra
            % and adapt all label vectors accordingly
            % We oinly keep the label of the ispi conditions (odd numbers)

            IsNaN = isnan(GrpConditionVec);
            GrpData(IsNaN, :) = [];
            GrpConditionVec(IsNaN, :) = [];
            SubjVec(IsNaN, :) = [];
            GrpRunVec(IsNaN, :) = [];

            OddConditions = logical(mod(GrpConditionVec, 2));

            % We check that the ipsi and contra condition we are about to
            % average come from the same subjects and run
            assert(all(SubjVec(OddConditions) == SubjVec(~OddConditions)));
            assert(all(GrpRunVec(OddConditions) == GrpRunVec(~OddConditions)));

            tmp = GrpData(OddConditions, :);
            tmp(:, :, 2) = GrpData(~OddConditions, :);
            GrpData = mean(tmp, 3);

            GrpConditionVec(~OddConditions, :) = [];
            SubjVec(~OddConditions, :) = [];
            GrpRunVec(~OddConditions, :) = [];

        end

        Data(iROI, 1).RoiName = ROIs{iROI}; %#ok<*AGROW>
        Data(iROI, 1).Data = GrpData;
        Data(iROI, 1).ConditionVec = GrpConditionVec;
        Data(iROI, 1).SubjVec = SubjVec;
        Data(iROI, 1).RunVec = GrpRunVec;

    end
end
