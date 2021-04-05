% (C) Copyright 2021 Remi Gau

function Data = LoadDataForRaster(Opt, Dirs, RoiName)

    fprintf('\n');

    [SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

    for iSub = 1:NbSub

        fprintf(' Loading %s\n', SubLs(iSub).name);

        SubDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);

        for hs = 1:2

            if hs == 1
                HsSufix = 'l';
            else
                HsSufix = 'r';
            end

            Filename = ReturnFilename('hs_roi_run_cdt_layer', ...
                                      SubLs(iSub).name, ...
                                      HsSufix, ...
                                      Opt.NbLayers, ...
                                      RoiName);

            RoiSaveFile = fullfile(SubDir, Filename);
            load(RoiSaveFile);

            RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, HsSufix);

            % remove all data from run 17 to avoid imbalalance
            if strcmp(SubLs(iSub).name, 'sub-06')

                RowsToSelect = ReturnRowsToSelect({RunVec, 17});

                RoiData(RowsToSelect, :) = [];
                ConditionVec(RowsToSelect, :) = [];
                LayerVec(RowsToSelect, :) = [];
                RunVec(RowsToSelect, :) = [];

            end

            Data(iSub, hs).RoiName = RoiName; %#ok<*AGROW>
            Data(iSub, hs).Data = RoiData;
            Data(iSub, hs).ConditionVec = ConditionVec;
            Data(iSub, hs).RunVec = RunVec;
            Data(iSub, hs).LayerVec = LayerVec;

        end

    end

end
