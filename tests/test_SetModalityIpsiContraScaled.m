function test_suite = test_SetModalityIpsiContraScaled %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_SetModalityIpsiContraScaledAudioScaled

    Models{1}.Ac = zeros(6, 1);

    Modality = 'A';
    Scaled = true();

    Models = SetModalityIpsiContraScaled(Models, Modality, Scaled);

    Expected{1}.Ac(:, 1) = zeros(6, 1);
    Expected{1}.Ac(1, 2, 2) = 1;
    Expected{1}.Ac(2, 2, 3) = 1;

    assertEqual(Models, Expected);
end

function test_SetModalityIpsiContraScaledTactileScaled

    Models{1}.Ac = zeros(6, 1);

    Modality = 'T';
    Scaled = true();

    Models = SetModalityIpsiContraScaled(Models, Modality, Scaled);

    Expected{1}.Ac(:, 1) = zeros(6, 1);
    Expected{1}.Ac(5, 2, 2) = 1;
    Expected{1}.Ac(6, 2, 3) = 1;

    assertEqual(Models, Expected);
end

function test_SetModalityIpsiContraScaledVisualScaled

    Models{1}.Ac = zeros(6, 1);

    Modality = 'V';
    Scaled = true();

    Models = SetModalityIpsiContraScaled(Models, Modality, Scaled);

    Expected{1}.Ac(:, 1) = zeros(6, 1);
    Expected{1}.Ac(3, 2, 2) = 1;
    Expected{1}.Ac(4, 2, 3) = 1;

    assertEqual(Models, Expected);
end

function test_SetModalityIpsiContraScaledAudioIdpdt

    Models{1}.Ac = zeros(6, 1);

    Modality = 'A';
    Scaled = false();

    Models = SetModalityIpsiContraScaled(Models, Modality, Scaled);

    Expected{1}.Ac(:, 1) = zeros(6, 1);
    Expected{1}.Ac(1, 2, 2) = 1;
    Expected{1}.Ac(2, 3, 3) = 1;

    assertEqual(Models, Expected);

end

function test_SetModalityIpsiContraScaledVisualIdpdt

    Models{1}.Ac = zeros(6, 1);

    Modality = 'V';
    Scaled = false();

    Models = SetModalityIpsiContraScaled(Models, Modality, Scaled);

    Expected{1}.Ac(:, 1) = zeros(6, 1);
    Expected{1}.Ac(3, 2, 2) = 1;
    Expected{1}.Ac(4, 3, 3) = 1;

    assertEqual(Models, Expected);

end

function test_SetModalityIpsiContraScaledTactileIdpdt

    Models{1}.Ac = zeros(6, 1);

    Modality = 'T';
    Scaled = false();

    Models = SetModalityIpsiContraScaled(Models, Modality, Scaled);

    Expected{1}.Ac(:, 1) = zeros(6, 1);
    Expected{1}.Ac(5, 2, 2) = 1;
    Expected{1}.Ac(6, 3, 3) = 1;

    assertEqual(Models, Expected);

end
