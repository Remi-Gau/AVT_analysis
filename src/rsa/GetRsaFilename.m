function Filename = GetRsaFilename(NbHs, hs, ROI, ConditionType, InputType, Opt)
    %
    % (C) Copyright 2021 Remi Gau
    hs_entity = GetHsEntity(NbHs, hs);

    Filename = ['group_rsa_results', ...
                '_roi-', ROI, ...
                hs_entity, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType), ...
                '.mat'];

    if Opt.PerformDeconvolution
        Filename = strrep(Filename, '.mat', '_deconvolved-1.mat');
    end

end
