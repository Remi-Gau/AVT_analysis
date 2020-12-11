% set up Models for PCM
% Johanna Zumer, 2017

plotflag = 1;

% Model 1: Null model for baseline: here we use a model which has all
% Patterns be independent
M{1}.type       = 'component';
M{1}.numGparams = 1;
M{1}.Gc         = eye(7);
M{1}.name       = 'null';

% Model 2: Free model as Noise ceiling
M{2}.type       = 'freechol';
M{2}.numCond    = 7;
M{2}.name       = 'noiseceiling';
M{2}           = pcm_prepFreeModel(M{2});

% % [See pcm_recipe_finger]
% figure;subplot(1,2,1);imagesc(Gm);subplot(1,2,2);imagesc(H*Gm*H');

% Define all matrices as RSA, then RDM = 1 - RSA, then convert to G = -0.5*H*RDM*H
H = eye(7) - ones(7) / 7;

% components

% 1) TIW, varying width and centre
% rsmodel_1a=zeros(7,7);
% rsmodel_1a(3:5,3:5)=1;
% G_1a=rsa2G(rsmodel_1a,plotflag,'model 1a');
rdmodel_1a = 1 - eye(7);
rdmodel_1a(3:5, 3:5) = 0;
G_1a = nearestSPD(rdm2G(rdmodel_1a, plotflag, 'model 1a'));

% rsmodel_1b=zeros(7,7);
% rsmodel_1b(2:6,2:6)=1;
% G_1b=rsa2G(rsmodel_1b,plotflag,'model 1b');
rdmodel_1b = 1 - eye(7);
rdmodel_1b(2:6, 2:6) = 0;
G_1b = nearestSPD(rdm2G(rdmodel_1b, plotflag, 'model 1b'));

% rsmodel_1c=zeros(7,7);
% rsmodel_1c(2:5,2:5)=1;
% G_1c=rsa2G(rsmodel_1c,plotflag,'model 1c');
rdmodel_1c = 1 - eye(7);
rdmodel_1c(2:5, 2:5) = 0;
G_1c = nearestSPD(rdm2G(rdmodel_1c, plotflag, 'model 1c'));

% rsmodel_1d=zeros(7,7);
% rsmodel_1d(3:6,3:6)=1;
% G_1d=rsa2G(rsmodel_1d,plotflag,'model 1d');
rdmodel_1d = 1 - eye(7);
rdmodel_1d(3:6, 3:6) = 0;
G_1d = nearestSPD(rdm2G(rdmodel_1d, plotflag, 'model 1d'));

% rsmodel_1e=zeros(7,7);
% rsmodel_1e(2:4,2:4)=1;
% G_1e=rsa2G(rsmodel_1e,plotflag,'model 1e');
rdmodel_1e = 1 - eye(7);
rdmodel_1e(2:4, 2:4) = 0;
G_1e = nearestSPD(rdm2G(rdmodel_1e, plotflag, 'model 1e'));

% rsmodel_1f=zeros(7,7);
% rsmodel_1f(4:6,4:6)=1;
% G_1f=rsa2G(rsmodel_1f,plotflag,'model 1f');
rdmodel_1f = 1 - eye(7);
rdmodel_1f(4:6, 4:6) = 0;
G_1f = nearestSPD(rdm2G(rdmodel_1f, plotflag, 'model 1f'));

% 2) asymmetry: AT will be similar to each other but different from TA (vice versa)
% rsmodel_2a=zeros(7,7);
% rsmodel_2a(1:4,1:4)=1;
% rsmodel_2a(4:7,4:7)=1;
% G_2a=rsa2G(rsmodel_2a,plotflag,'model 2');
rdmodel_2a = 1 - eye(7);
rdmodel_2a(1:4, 1:4) = 0;
rdmodel_2a(4:7, 4:7) = 0;
G_2a = nearestSPD(rdm2G(rdmodel_2a, plotflag, 'model 2'));

% 3) symmetric pair: TA70 will be more like itself and AT70 than others
% rsmodel_3a=zeros(7,7);
% rsmodel_3a(1,7)=1;
% rsmodel_3a(2,6)=1;
% rsmodel_3a(3,5)=1;
% rsmodel_3a(4,4)=1;
% rsmodel_3a(5,3)=1;
% rsmodel_3a(6,2)=1;
% rsmodel_3a(7,1)=1;
% G_3a=rsa2G(rsmodel_3a,plotflag,'model 3');
rdmodel_3a = 1 - eye(7);
rdmodel_3a(1, 7) = 0;
rdmodel_3a(2, 6) = 0;
rdmodel_3a(3, 5) = 0;
rdmodel_3a(4, 4) = 0;
rdmodel_3a(5, 3) = 0;
rdmodel_3a(6, 2) = 0;
rdmodel_3a(7, 1) = 0;
G_3a = nearestSPD(rdm2G(rdmodel_3a, plotflag, 'model 3'));

% Interaction terms:
% interact_1a2a=rsmodel_1a.*rsmodel_2a;
% interact_1b2a=rsmodel_1b.*rsmodel_2a;
% interact_1a3a=rsmodel_1a.*rsmodel_3a;
% interact_1b3a=rsmodel_1b.*rsmodel_3a;
% G_1a2a=rsa2G(interact_1a2a,plotflag,'model 3');
% G_1b2a=rsa2G(interact_1b2a,plotflag,'model 3');
% G_1a3a=rsa2G(interact_1a3a,plotflag,'model 3');
% G_1b3a=rsa2G(interact_1b3a,plotflag,'model 3');
interact_1a2a = rdmodel_1a .* rdmodel_2a;
interact_1b2a = rdmodel_1b .* rdmodel_2a;
interact_1a3a = rdmodel_1a .* rdmodel_3a;
interact_1b3a = rdmodel_1b .* rdmodel_3a;
interact_2a3a = rdmodel_2a .* rdmodel_3a;
G_1a2a = nearestSPD(rdm2G(interact_1a2a, plotflag, 'model 1a X 2'));
G_1b2a = nearestSPD(rdm2G(interact_1b2a, plotflag, 'model 1b X 2'));
G_1a3a = nearestSPD(rdm2G(interact_1a3a, plotflag, 'model 1a X 3'));
G_1b3a = nearestSPD(rdm2G(interact_1b3a, plotflag, 'model 1b X 3'));
G_2a3a = nearestSPD(rdm2G(interact_2a3a, plotflag, 'model 2 X 3'));

% Gi_1a2a=G_1a.*G_2a;
% Gi_1b2a=G_1b.*G_2a;
% Gi_1a3a=G_1a.*G_3a;
% Gi_1b3a=G_1b.*G_3a;

% % Model 3: TIW a
% M{3}.type       = 'component';
% M{3}.numGparams = 1;
% M{3}.Gc(:,:,1)  = G_1a;
% M{3}.name       = 'TIW1a';
%
% % Model 4: TIW b
% M{4}.type       = 'component';
% M{4}.numGparams = 1;
% M{4}.Gc(:,:,1)  = G_1b;
% M{4}.name       = 'TIW1b';

% % 7 possible models without interaction terms  (see notes 11/9/17)
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

% Model 10: TIW a and b
M{10}.type       = 'component';
M{10}.numGparams = 3;
M{10}.Gc(:, :, 1)  = G_1a;
M{10}.Gc(:, :, 2)  = G_1b;
M{10}.Gc(:, :, 3)  = eye(7);
M{10}.name       = 'TIW1a1b_eye';

% Model 11: Asymmetry
M{11}.type       = 'component';
M{11}.numGparams = 2;
M{11}.Gc(:, :, 1)  = G_2a;
M{11}.Gc(:, :, 2)  = eye(7);
M{11}.name       = 'Asym2_eye';

% Model 12: Symmetric Pairs
M{12}.type       = 'component';
M{12}.numGparams = 2;
M{12}.Gc(:, :, 1)  = G_3a;
M{12}.Gc(:, :, 2)  = eye(7);
M{12}.name       = 'SymPair3_eye';

% Model 13: TIW a and b;  Asymmetry
M{13}.type       = 'component';
M{13}.numGparams = 4;
M{13}.Gc(:, :, 1)  = G_1a;
M{13}.Gc(:, :, 2)  = G_1b;
M{13}.Gc(:, :, 3)  = G_2a;
M{13}.Gc(:, :, 4)  = eye(7);
M{13}.name       = 'TIW1a1b_Asym2_eye';

% Model 14: TIW a and b;  Symmetric Pairs
M{14}.type       = 'component';
M{14}.numGparams = 4;
M{14}.Gc(:, :, 1)  = G_1a;
M{14}.Gc(:, :, 2)  = G_1b;
M{14}.Gc(:, :, 3)  = G_3a;
M{14}.Gc(:, :, 4)  = eye(7);
M{14}.name       = 'TIW1a1b_SymPair3_eye';

% Model 15: Asymmetry;  Symmetric Pairs
M{15}.type       = 'component';
M{15}.numGparams = 3;
M{15}.Gc(:, :, 1)  = G_2a;
M{15}.Gc(:, :, 2)  = G_3a;
M{15}.Gc(:, :, 3)  = eye(7);
M{15}.name       = 'Asym2_SymPair3_eye';

% Model 16: TIW a and b;  Asymmetry;  Symmetric Pairs
M{16}.type       = 'component';
M{16}.numGparams = 5;
M{16}.Gc(:, :, 1)  = G_1a;
M{16}.Gc(:, :, 2)  = G_1b;
M{16}.Gc(:, :, 3)  = G_2a;
M{16}.Gc(:, :, 4)  = G_3a;
M{16}.Gc(:, :, 5)  = eye(7);
M{16}.name       = 'TIW1a1b_Asym2_SymPair3_eye';

% % % 3 (reduced) models with interaction terms
% % Model 10: TIW a and b;  Asymmetry; Interaction_TIW_Asym
% M{10}.type       = 'component';
% M{10}.numGparams = 5;
% M{10}.Gc(:,:,1)  = G_1a;
% M{10}.Gc(:,:,2)  = G_1b;
% M{10}.Gc(:,:,3)  = G_2a;
% M{10}.Gc(:,:,4)  = G_1a2a;
% M{10}.Gc(:,:,5)  = G_1b2a;
% M{10}.name       = 'TIW1a1b_Asym2_IntTIWAsym';
%
% % Model 11: TIW a and b;  Sym Pairs; Interaction_TIW_SymPair
% M{11}.type       = 'component';
% M{11}.numGparams = 5;
% M{11}.Gc(:,:,1)  = G_1a;
% M{11}.Gc(:,:,2)  = G_1b;
% M{11}.Gc(:,:,3)  = G_3a;
% M{11}.Gc(:,:,4)  = G_1a3a;
% M{11}.Gc(:,:,5)  = G_1b3a;
% M{11}.name       = 'TIW1a1b_Asym2_IntTIWSymPair';
%
% % Model 12: Asymmetry;  Sym Pairs; Interaction_Asym_SymPair
% M{12}.type       = 'component';
% M{12}.numGparams = 3;
% M{12}.Gc(:,:,1)  = G_2a;
% M{12}.Gc(:,:,2)  = G_3a;
% M{12}.Gc(:,:,3)  = G_2a3a;
% M{12}.name       = 'TIW1a1b_Asym2_IntTIWSymPair';
%
% % % 7 models with all main effects and varying number of interactions
% % Model 13: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_TIW_Asym
% M{13}.type       = 'component';
% M{13}.numGparams = 6;
% M{13}.Gc(:,:,1)  = G_1a;
% M{13}.Gc(:,:,2)  = G_1b;
% M{13}.Gc(:,:,3)  = G_2a;
% M{13}.Gc(:,:,4)  = G_3a;
% M{13}.Gc(:,:,5)  = G_1a2a;
% M{13}.Gc(:,:,6)  = G_1b2a;
% M{13}.name       = 'TIW1a1b_Asym2_SymPair_IntTIWAsym';
%
% % Model 14: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_TIW_SymPair
% M{14}.type       = 'component';
% M{14}.numGparams = 6;
% M{14}.Gc(:,:,1)  = G_1a;
% M{14}.Gc(:,:,2)  = G_1b;
% M{14}.Gc(:,:,3)  = G_2a;
% M{14}.Gc(:,:,4)  = G_3a;
% M{14}.Gc(:,:,5)  = G_1a3a;
% M{14}.Gc(:,:,6)  = G_1b3a;
% M{14}.name       = 'TIW1a1b_Asym2_SymPair_IntTIWSymPair';
%
% % Model 15: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_Asym_SymPair
% M{15}.type       = 'component';
% M{15}.numGparams = 5;
% M{15}.Gc(:,:,1)  = G_1a;
% M{15}.Gc(:,:,2)  = G_1b;
% M{15}.Gc(:,:,3)  = G_2a;
% M{15}.Gc(:,:,4)  = G_3a;
% M{15}.Gc(:,:,5)  = G_2a3a;
% M{15}.name       = 'TIW1a1b_Asym2_SymPair_IntAsymSymPair';
%
% % Model 16: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_TIW_Asym; Interaction_TIW_SymPair
% M{16}.type       = 'component';
% M{16}.numGparams = 8;
% M{16}.Gc(:,:,1)  = G_1a;
% M{16}.Gc(:,:,2)  = G_1b;
% M{16}.Gc(:,:,3)  = G_2a;
% M{16}.Gc(:,:,4)  = G_3a;
% M{16}.Gc(:,:,5)  = G_1a2a;
% M{16}.Gc(:,:,6)  = G_1b2a;
% M{16}.Gc(:,:,7)  = G_1a3a;
% M{16}.Gc(:,:,8)  = G_1b3a;
% M{16}.name       = 'TIW1a1b_Asym2_SymPair_IntTIWAsym_IntTIWSymPair';
%
% % Model 17: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_TIW_Asym; Interaction_Asym_SymPair
% M{17}.type       = 'component';
% M{17}.numGparams = 7;
% M{17}.Gc(:,:,1)  = G_1a;
% M{17}.Gc(:,:,2)  = G_1b;
% M{17}.Gc(:,:,3)  = G_2a;
% M{17}.Gc(:,:,4)  = G_3a;
% M{17}.Gc(:,:,5)  = G_1a2a;
% M{17}.Gc(:,:,6)  = G_1b2a;
% M{17}.Gc(:,:,7)  = G_2a3a;
% M{17}.name       = 'TIW1a1b_Asym2_SymPair_IntTIWAsym_IntAsymSymPair';
%
% % Model 18: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_TIW_SymPair; Interaction_Asym_SymPair
% M{18}.type       = 'component';
% M{18}.numGparams = 7;
% M{18}.Gc(:,:,1)  = G_1a;
% M{18}.Gc(:,:,2)  = G_1b;
% M{18}.Gc(:,:,3)  = G_2a;
% M{18}.Gc(:,:,4)  = G_3a;
% M{18}.Gc(:,:,5)  = G_1a3a;
% M{18}.Gc(:,:,6)  = G_1b3a;
% M{18}.Gc(:,:,7)  = G_2a3a;
% M{18}.name       = 'TIW1a1b_Asym2_SymPair_IntTIWSymPair_IntAsymSymPair';
%
% % Model 19: TIW a and b;  Asymmetry;  Sym Pairs; Interaction_TIW_Asym; Interaction_TIW_SymPair; Interaction_Asym_SymPair
% M{19}.type       = 'component';
% M{19}.numGparams = 9;
% M{19}.Gc(:,:,1)  = G_1a;
% M{19}.Gc(:,:,2)  = G_1b;
% M{19}.Gc(:,:,3)  = G_2a;
% M{19}.Gc(:,:,4)  = G_3a;
% M{19}.Gc(:,:,5)  = G_1a2a;
% M{19}.Gc(:,:,6)  = G_1b2a;
% M{19}.Gc(:,:,7)  = G_1a3a;
% M{19}.Gc(:,:,8)  = G_1b3a;
% M{19}.Gc(:,:,9)  = G_2a3a;
% M{19}.name       = 'TIW1a1b_Asym2_SymPair_IntTIWAsym_IntTIWSymPair_IntAsymSymPair';

% % Model 9: TIW a and b;  Asymmetry;  Symmetric Pairs
% M{20}.type       = 'component';
% M{20}.numGparams = 6;
% M{20}.Gc(:,:,1)  = G_1a;
% M{20}.Gc(:,:,2)  = G_1b;
% M{20}.Gc(:,:,3)  = G_2a;
% M{20}.Gc(:,:,4)  = G_3a;
% M{20}.Gc(:,:,5)  = eye(7);
% M{20}.Gc(:,:,6)  = rdm2G(eye(7),0);
% M{20}.name       = 'TIW1a1b_Asym2_SymPair3_eye_eye2G';
%
% % Model 9: TIW a and b;  Asymmetry;  Symmetric Pairs
% M{21}.type       = 'component';
% M{21}.numGparams = 5;
% M{21}.Gc(:,:,1)  = G_1a;
% M{21}.Gc(:,:,2)  = G_1b;
% M{21}.Gc(:,:,3)  = G_2a;
% M{21}.Gc(:,:,4)  = G_3a;
% M{21}.Gc(:,:,5)  = rdm2G(eye(7),0);
% M{21}.name       = 'TIW1a1b_Asym2_SymPair3_eye2G';
%

save([pwd 'pcm_models.mat'], 'M');
