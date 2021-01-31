function test_suite = test_SetModelSixConditions %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_SetModelSixConditionsAllScaled

    Models{1}.Ac = [];

    ConditionScaled = {['A', 'V', 'T'], []};
    IpsiContraScaled = true(1,3);

    Models = SetModelSixConditions(Models, ConditionScaled, IpsiContraScaled);

    Expected{1}.Ac = zeros(6, 1, 6);
    Expected{1}.Ac(1, 1, 1) = 1;
    Expected{1}.Ac(2, 1, 2) = 1;
    Expected{1}.Ac(3, 1, 3) = 1;
    Expected{1}.Ac(4, 1, 4) = 1;
    Expected{1}.Ac(5, 1, 5) = 1;
    Expected{1}.Ac(6, 1, 6) = 1;  

    assertEqual(Models{end}, Expected{1});
    
    clear Expected
    
    %%
    Models{1}.Ac = [];
    
    ConditionScaled = {['A', 'V', 'T'], []};
    IpsiContraScaled = false(1,3);

    Models = SetModelSixConditions(Models, ConditionScaled, IpsiContraScaled);

    Expected{1}.Ac = zeros(6, 2, 6);
    Expected{1}.Ac(1, 1, 1) = 1;
    Expected{1}.Ac(2, 2, 2) = 1;
    Expected{1}.Ac(3, 1, 3) = 1;
    Expected{1}.Ac(4, 2, 4) = 1;
    Expected{1}.Ac(5, 1, 5) = 1;
    Expected{1}.Ac(6, 2, 6) = 1;    

    assertEqual(Models{end}, Expected{1});
    
end


function test_SetModelSixConditionsAllIdpdt

    Models{1}.Ac = [];

    ConditionScaled = {[], ['A', 'V', 'T']};
    IpsiContraScaled = true(1,3);

    Models = SetModelSixConditions(Models, ConditionScaled, IpsiContraScaled);

    Expected{1}.Ac = zeros(6, 1, 6);
    Expected{1}.Ac(1, 1, 1) = 1;
    Expected{1}.Ac(2, 1, 2) = 1;
    Expected{1}.Ac(3, 2, 3) = 1;
    Expected{1}.Ac(4, 2, 4) = 1;
    Expected{1}.Ac(5, 3, 5) = 1;
    Expected{1}.Ac(6, 3, 6) = 1;  

    assertEqual(Models{end}, Expected{1});
    
    clear Expected
    
    Models{1}.Ac = [];

    ConditionScaled = {[], ['A', 'V', 'T']};
    IpsiContraScaled = false(1,3);

    Models = SetModelSixConditions(Models, ConditionScaled, IpsiContraScaled);

    Expected{1}.Ac = zeros(6, 1, 6);
    Expected{1}.Ac(1, 1, 1) = 1;
    Expected{1}.Ac(2, 2, 2) = 1;
    Expected{1}.Ac(3, 3, 3) = 1;
    Expected{1}.Ac(4, 4, 4) = 1;
    Expected{1}.Ac(5, 5, 5) = 1;
    Expected{1}.Ac(6, 6, 6) = 1;  

    assertEqual(Models{end}, Expected{1});
    
    clear Expected

end

function test_SetModelSixConditionsAudioIdpdt

    Models{1}.Ac = [];

    ConditionScaled = {['V', 'T'], ['A']};
    IpsiContraScaled = [true(), false(), false()];

    Models = SetModelSixConditions(Models, ConditionScaled, IpsiContraScaled);

    Expected{1}.Ac = zeros(6, 1, 6);
    Expected{1}.Ac(1, 1, 1) = 1;
    Expected{1}.Ac(2, 1, 2) = 1;
    Expected{1}.Ac(3, 2, 3) = 1;
    Expected{1}.Ac(4, 3, 4) = 1;
    Expected{1}.Ac(5, 2, 5) = 1;
    Expected{1}.Ac(6, 3, 6) = 1;  

    assertEqual(Models{end}, Expected{1});
    
    clear Expected

end