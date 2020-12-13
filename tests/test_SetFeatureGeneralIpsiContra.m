% (C) Copyright 2020 Remi Gau

function test_suite = test_SetFeatureGeneralIpsiContra %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_SetFeatureGeneralIpsiContraBasic
    
    Do = 1;

    Models{1}.Ac = [1 ; zeros(5,1)];
    Models = SetFeatureGeneralIpsiContra(Models, Do);
    
    Expected{1}.Ac(:, 1) = [1 ; zeros(5,1)];
    Expected{1}.Ac(:, 2, 2) =  [1 0 1 0 1 0]; 
    Expected{1}.Ac(:, 3, 3) =  [0 1 0 1 0 1];
    
    assertEqual(Models, Expected);

end