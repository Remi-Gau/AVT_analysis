function [GrpData, GrpConditionVec, GrpRunVec] = LoadAndPreparePcmData(ROI, InputDir, Opt, InputType)
    %
    % (C) Copyright 2020 Remi Gau

    [SubLs, NbSub] = GetSubjectList(InputDir);

    fprintf('\n %s\n', ROI);

    GrpData = {};
    GrpConditionVec = {};
    GrpRunVec = {};

    clear G_hat G Gm COORD;

    for ihs = 1:2

        HsSufix = 'l';
        if ihs == 2
            HsSufix = 'r';
        end

        fprintf('\n  Hemisphere: %s\n', HsSufix);

        for iSub = 1:NbSub

            fprintf('   Loading %s\n', SubLs(iSub).name);

            SubDir = fullfile(InputDir, SubLs(iSub).name);

            Filename = GetNameFileToLoad( ...
                                         SubDir, ...
                                         SubLs(iSub).name, ...
                                         HsSufix, ...
                                         Opt.NbLayers, ...
                                         ROI, ...
                                         InputType);

            load(Filename, 'RoiData', 'ConditionVec', 'RunVec');
            LayerVec = ones(size(ConditionVec));
            if strcmp(InputType, 'ROI')
                load(Filename, 'LayerVec');
            end

            [RoiData, RunVec, ConditionVec, LayerVec] = CheckInput(RoiData, ...
                                                                   RunVec, ...
                                                                   ConditionVec, ...
                                                                   Opt.Targets, ...
                                                                   LayerVec);

            RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, HsSufix, Opt.ReassignIpsiContra);

            % If we have the layers data on several rows of the data
            % matrix we put them back on a single row
            CvMat = [ConditionVec RunVec LayerVec];
            if strcmpi(InputType, 'roi') && strcmpi(Space, 'surf')
                [RoiData, CvMat] = LineariseLaminarData(RoiData, CvMat);
            end
            ConditionVec = CvMat(:, 1);
            RunVec = CvMat(:, 2);

            GrpData{iSub, ihs} = RoiData; %#ok<*SAGROW>
            GrpConditionVec{iSub} = ConditionVec;
            GrpRunVec{iSub} = RunVec;

        end

    end

    GrpData = CombineDataBothHemisphere(GrpData, Opt);

end
