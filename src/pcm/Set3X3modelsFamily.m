function [Families, Families2] = Set3X3modelsFamily()

    % These are the 12 models from the PCM
    % M{1}.name = 'all_scaled';
    % M{2}.name = 'all_idpdt';
    % M{3}.name = 'all_scaled_&_idpdt';
    %
    % M{4}.name = 'A idpdt - V,T scaled';
    % M{5}.name = 'V idpdt - A,T scaled';
    % M{6}.name = 'T idpdt - V,A scaled';
    %
    % M{7}.name = 'A idpdt+scaled - V,T scaled';
    % M{8}.name = 'V idpdt+scaled - A,T scaled';
    % M{9}.name = 'T idpdt+scaled - V,A scaled';
    %
    % M{10}.name = 'A idpdt+scaled V - T idpdt';
    % M{11}.name = 'A idpdt+scaled T - V idpdt';
    % M{12}.name = 'V idpdt+scaled T - A idpdt';

    %% Sorting models for each family comparison

    family_names = { ...
                    'Idpdt', ...
                    'Scaled', ...
                    'Scaled_Idpdt'};

    family_names2 = { ...
                     'Idpdt + Scaled_Idpdt', ...
                     'Scaled'};

    CdtComb = ['AV'; 'AT'; 'VT'];

    % Models to include for each modality for the family comparison
    A_Idpdt_V = [2 4 5 11 12];
    A_Scaled_V = [1 6 9];
    A_Scaled_Idpdt_V = [3 7 8 10];

    Cdt{1} = [A_Idpdt_V A_Scaled_V A_Scaled_Idpdt_V];

    A_Idpdt_T = [2 4 6 10 12];
    A_Scaled_T = [1 5 8];
    A_Scaled_Idpdt_T = [3 7 9 11];

    Cdt{2} = [A_Idpdt_T A_Scaled_T A_Scaled_Idpdt_T];

    V_Idpdt_T = [2 5 6 10 11];
    V_Scaled_T = [1 4 7];
    V_Scaled_Idpdt_T = [3 8 9 12];

    Cdt{3} = [V_Idpdt_T V_Scaled_T V_Scaled_Idpdt_T];

    % Create the families
    for iCdt = 1:3

        Families{iCdt} = ...
          struct( ...
                 'names', [], ...
                 'partition', [1 1 1 1 1 2 2 2 3 3 3 3], ...
                 'modelorder', [], ...
                 'infer', 'RFX', ...
                 'Nsamp', 1e4, ...
                 'prior', 'F-unity'); %#ok<*SAGROW>

        for iFam = 1:3
            Families{iCdt}.names{iFam} = ...
              [CdtComb(iCdt, 1) '_' ...
               family_names{iFam} '_' ...
               CdtComb(iCdt, 2)];
        end

        Families2{iCdt} = ...
          struct( ...
                 'names', [], ...
                 'partition', [1 1 1 1 1 2 2 2 1 1 1 1], ...
                 'modelorder', [], ...
                 'infer', 'RFX', ...
                 'Nsamp', 1e4, ...
                 'prior', 'F-unity'); %#ok<*SAGROW>

        for iFam = 1:2
            Families2{iCdt}.names{iFam} = ...
              [CdtComb(iCdt, 1) '_' ...
               family_names2{iFam} '_' ...
               CdtComb(iCdt, 2)];
        end

        % The field modelOrder will be used to only extract the likelihood of the models of interest
        Families{iCdt}.modelorder = Cdt{iCdt};
        Families2{iCdt}.modelorder = Cdt{iCdt};

    end

end
