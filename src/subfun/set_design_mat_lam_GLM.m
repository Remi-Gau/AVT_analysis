function DesMat = set_design_mat_lam_GLM(NbLayers, Quad)
  DesMat = (1:NbLayers) - mean(1:NbLayers);
  if nargin < 2 || strcmpl(Quad, 'quad')
    DesMat = [ones(NbLayers, 1) DesMat'];
  else
    DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
  end
  DesMat = spm_orth(DesMat);
end
