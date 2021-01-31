function M = SetFreeModelPcm(M, NbConditions)
    
    % Free model as Noise ceiling
    M{end + 1}.type       = 'freechol';
    M{end}.numCond    = NbConditions;
    M{end}.name       = 'noiseceiling';
    M{end}           = pcm_prepFreeModel(M{end});
    M{end}.fitAlgorithm = 'minimize';
    
end