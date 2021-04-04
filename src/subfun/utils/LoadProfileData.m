% (C) Copyright 2021 Remi Gau

function [Data, CondNamesIpsiContra] = LoadProfileData(Opt, ROIs, InputDir) %#ok<STOUT>

    for iROI =  1:numel(ROIs)

        Filename = ['Group-roi-', ROIs{iROI}, ...
                    '_average-', Opt.AverageType, ...
                    '_nbLayers-', num2str(Opt.NbLayers), '.mat' ...
                   ];

        load(fullfile(InputDir, Filename));

        Data(iROI, 1).RoiName = ROIs{iROI}; %#ok<*AGROW>
        Data(iROI, 1).Data = GrpData;
        Data(iROI, 1).ConditionVec = GrpConditionVec;
        Data(iROI, 1).SubjVec = SubjVec;
        Data(iROI, 1).RunVec = GrpRunVec;

    end
end
