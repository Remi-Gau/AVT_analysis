% (C) Copyright 2020 Remi Gau

function M = SetSubset6X6Models(AuditoryOrVisual)

% {['scaled'], ['independent']}
% 
% {[], ['A', 'V', 'T']}
% {['A', 'V', 'T'], []}
% {['A'], ['V', 'T']}
%
% [IpsiContraAudioScaled IpsiContraVisualScaled IpsiContraTactileScaled]
% true(1,3)
% false(1,3)
% [true() false() false()]
% ...


    if nargin < 1 || isempty(AuditoryOrVisual)
        AuditoryOrVisual = 'auditory';
    end

    NbConditions = 6;

    Alg = 'NR'; % 'minimize'; 'NR'

    M = {};

    M = SetNullModelPcm(M, NbConditions);
    
    
    M = SetFreeModelPcm(M, NbConditions);
    
end
