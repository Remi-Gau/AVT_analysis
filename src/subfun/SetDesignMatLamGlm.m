function DesMat = SetDesignMatLamGlm(NbLayers, Quad)
    DesMat = (1:NbLayers) - mean(1:NbLayers);
    if nargin < 2 || ~Quad
        DesMat = [ones(NbLayers, 1) DesMat'];
    else
        DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
    end
    DesMat = spm_orth(DesMat);
end
