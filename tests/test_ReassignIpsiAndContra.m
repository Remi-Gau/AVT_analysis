% (C) Copyright 2020 Remi Gau

function test_suite = test_ReassignIpsiAndContra %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_ReassignIpsiAndContraBasic()

    %%
    RoiData = repmat([zeros(1, 3); ones(1, 3)], 3, 1);
    ConditionVec = (1:6)';
    Hemisphere = 1;
    DoFeaturePooling = false;

    RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, Hemisphere, DoFeaturePooling);

    assertEqual(RoiData, repmat([zeros(1, 3); ones(1, 3)], 3, 1));

    %%
    RoiData = repmat([zeros(1, 3); ones(1, 3)], 3, 1);
    ConditionVec = (1:6)';
    Hemisphere = 1;
    DoFeaturePooling = true;
    RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, Hemisphere, DoFeaturePooling);

    assertEqual(RoiData, repmat([zeros(1, 3); ones(1, 3)], 3, 1));

    %%
    RoiData = repmat([zeros(1, 3); ones(1, 3)], 3, 1);
    ConditionVec = (1:6)';
    Hemisphere = 2;
    DoFeaturePooling = true;
    RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, Hemisphere, DoFeaturePooling);

    assertEqual(RoiData, repmat([ones(1, 3); zeros(1, 3)], 3, 1));

end
