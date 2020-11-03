% set up Models for PCM
% Johanna Zumer, 2017

plotflag = 0;

sim1_RDM_G;

% Model 1: One null model that has all conditions be independent
M{1}.type       = 'component';
M{1}.numGparams = 1;
M{1}.Gc         = eye(7);
M{1}.name       = 'null_eye';

% Model 2: Free model as Noise ceiling
M{2}.type       = 'freechol';
M{2}.numCond    = 7;
M{2}.name       = 'noiseceiling';
M{2}           = pcm_prepFreeModel(M{2});

% Define all matrices as RDM, then convert to G = -0.5*H*RDM*H
H = eye(7) - ones(7) / 7;

% Model 3: TIW a and b
M{3}.type       = 'component';
M{3}.numGparams = 2;
M{3}.Gc(:, :, 1)  = G_1a;
M{3}.Gc(:, :, 2)  = G_1b;
M{3}.name       = 'TIW1a1b';

% Model 4: Asymmetry
M{4}.type       = 'component';
M{4}.numGparams = 1;
M{4}.Gc(:, :, 1)  = G_2a;
M{4}.name       = 'Asym2';

% Model 5: Symmetric Pairs
M{5}.type       = 'component';
M{5}.numGparams = 1;
M{5}.Gc(:, :, 1)  = G_3a;
M{5}.name       = 'SymPair3';

% Model 6: TIW a and b;  Asymmetry
M{6}.type       = 'component';
M{6}.numGparams = 3;
M{6}.Gc(:, :, 1)  = G_1a;
M{6}.Gc(:, :, 2)  = G_1b;
M{6}.Gc(:, :, 3)  = G_2a;
M{6}.name       = 'TIW1a1b_Asym2';

% Model 7: TIW a and b;  Symmetric Pairs
M{7}.type       = 'component';
M{7}.numGparams = 3;
M{7}.Gc(:, :, 1)  = G_1a;
M{7}.Gc(:, :, 2)  = G_1b;
M{7}.Gc(:, :, 3)  = G_3a;
M{7}.name       = 'TIW1a1b_SymPair3';

% Model 8: Asymmetry;  Symmetric Pairs
M{8}.type       = 'component';
M{8}.numGparams = 2;
M{8}.Gc(:, :, 1)  = G_2a;
M{8}.Gc(:, :, 2)  = G_3a;
M{8}.name       = 'Asym2_SymPair3';

% Model 9: TIW a and b;  Asymmetry;  Symmetric Pairs
M{9}.type       = 'component';
M{9}.numGparams = 4;
M{9}.Gc(:, :, 1)  = G_1a;
M{9}.Gc(:, :, 2)  = G_1b;
M{9}.Gc(:, :, 3)  = G_2a;
M{9}.Gc(:, :, 4)  = G_3a;
M{9}.name       = 'TIW1a1b_Asym2_SymPair3';

% Model 10: TIW a and b; and eye
M{10}.type       = 'component';
M{10}.numGparams = 3;
M{10}.Gc(:, :, 1)  = G_1a;
M{10}.Gc(:, :, 2)  = G_1b;
M{10}.Gc(:, :, 3)  = eye(7);
M{10}.name       = 'TIW1a1b_eye';

% Model 11: Asymmetry; and eye
M{11}.type       = 'component';
M{11}.numGparams = 2;
M{11}.Gc(:, :, 1)  = G_2a;
M{11}.Gc(:, :, 2)  = eye(7);
M{11}.name       = 'Asym2_eye';

% Model 12: Symmetric Pairs; and eye
M{12}.type       = 'component';
M{12}.numGparams = 2;
M{12}.Gc(:, :, 1)  = G_3a;
M{12}.Gc(:, :, 2)  = eye(7);
M{12}.name       = 'SymPair3_eye';

% Model 13: TIW a and b;  Asymmetry; and eye
M{13}.type       = 'component';
M{13}.numGparams = 4;
M{13}.Gc(:, :, 1)  = G_1a;
M{13}.Gc(:, :, 2)  = G_1b;
M{13}.Gc(:, :, 3)  = G_2a;
M{13}.Gc(:, :, 4)  = eye(7);
M{13}.name       = 'TIW1a1b_Asym2_eye';

% Model 14: TIW a and b;  Symmetric Pairs; and eye
M{14}.type       = 'component';
M{14}.numGparams = 4;
M{14}.Gc(:, :, 1)  = G_1a;
M{14}.Gc(:, :, 2)  = G_1b;
M{14}.Gc(:, :, 3)  = G_3a;
M{14}.Gc(:, :, 4)  = eye(7);
M{14}.name       = 'TIW1a1b_SymPair3_eye';

% Model 15: Asymmetry;  Symmetric Pairs; and eye
M{15}.type       = 'component';
M{15}.numGparams = 3;
M{15}.Gc(:, :, 1)  = G_2a;
M{15}.Gc(:, :, 2)  = G_3a;
M{15}.Gc(:, :, 3)  = eye(7);
M{15}.name       = 'Asym2_SymPair3_eye';

% Model 16: TIW a and b;  Asymmetry;  Symmetric Pairs; and eye
M{16}.type       = 'component';
M{16}.numGparams = 5;
M{16}.Gc(:, :, 1)  = G_1a;
M{16}.Gc(:, :, 2)  = G_1b;
M{16}.Gc(:, :, 3)  = G_2a;
M{16}.Gc(:, :, 4)  = G_3a;
M{16}.Gc(:, :, 5)  = eye(7);
M{16}.name       = 'TIW1a1b_Asym2_SymPair3_eye';

% Model 17: Complete null model assuming no activity or covariance anywhere
M{17}.type       = 'component';
M{17}.numGparams = 1;
M{17}.Gc         = nearestSPD(zeros(7));
M{17}.name       = 'null_zero';

for mm = 1:numel(M)
  %   M{mm}.fitAlgorithm='NR'; % NR or minimize
  M{mm}.fitAlgorithm = 'minimize'; % NR or minimize
end

save(['pcm_models.mat'], 'M');
