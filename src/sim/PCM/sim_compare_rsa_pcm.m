%%
clear;
clc;
close all;

NbFeatures = 10000;
NbCdt = 6;
NbSess = 20;

% Z is the design matrix for the activity patterns
% assume 6 conditions with 20 examplars per condition, same for all subjects
Z = zeros(NbSess, NbCdt);
Z(1:NbSess, 1) = 1;
Z(1 + NbSess * 1:NbSess * 2, 2) = 1;
Z(1 + NbSess * 2:NbSess * 3, 3) = 1;
Z(1 + NbSess * 3:NbSess * 4, 4) = 1;
Z(1 + NbSess * 4:NbSess * 5, 5) = 1;
Z(1 + NbSess * 5:NbSess * 6, 6) = 1;

% the desgin matrix for the fixed effects is the same as the one for
% patterns
X = Z;

% B is the beta for the fixed effects (condition means)
% for auditory ROI
B = [1; ... A contra
     1; ... A ipsi
     1; ... V Contra
     1; ... V Ipsi
     1; ... T contra
     1]; % T ipsi

CondNames = { ...
             'A ipsi', 'A contra', ...
             'V ipsi', 'V contra', ...
             'T ipsi', 'T contra' ...
            };

s = 0.1;
sig = 1;

partVec = repmat((1:NbSess)', [NbCdt 1]);
condVec = repmat(1:NbCdt, [NbSess 1]);
condVec = condVec(:);

%%
M = {};
M{end + 1}.type       = 'feature';
M{end}.Ac = [];
Col = [1 1 2 2 3 3];
for i = 1:2:numel(CondNames)
    A = zeros(1, numel(CondNames));
    A(i:i + 1) = 1;
    M{end}.Ac(:, Col(i), Col(i)) = A;
end
M{end}.name       = 'A+V+T';
M{end}.numGparams = size(M{end}.Ac, 3);
M{end}.theta0 = [1 2 1];

[G] = pcm_calculateG(M{1}, M{1}.theta0);

%%
[Y0, Y1] = Generate_PCM_data(Z, G, s, sig, NbFeatures, X, B);
Y = Y1;

%%
% estimate G matrix
G_hat = pcm_estGCrossval(Y, partVec, condVec);

% compute RSA distances (A --> B) in a cross validated fashion
A =  rsa.distanceLDC(Y, partVec, condVec);

% because when doing cross validation distance A --> B can be different
% from B-->A we recompute the RSA in the other direction and take the
% mean of both directions

% compute RSA distances (B --> A) in a cross validated fashion
% flipup the data and the partition vector means that condition label
% used to be 1:6 is now 6:-1:1
B =  rsa.distanceLDC(flipud(Y), flipud(partVec), condVec);
% flip the distance "back"
B = fliplr(B);
B = [B(1:2) B(4) B(7) B(11) B(3) B(5) B(8) B(12) B(6) B(9) B(13) B(10) B(14:15)];
% take the mean
RDMs_CV = squareform(mean([A; B]));

%%
% compare the RSA results we get from the PCM via the G martrix and
% that of the RSA toolbox
fprintf('\n   Difference \n');

c = pcm_indicatorMatrix('allpairs', 1:numel(CondNames));
H = eye(numel(CondNames)) - ones(numel(CondNames)) / numel(CondNames);

G;

G_hat;

H * G_hat * H';

RDMs_CV;

squareform(diag(c * G_hat * c'));
