 clear; close all
% cd C:\UTA\Papers\Bham\Remi_AVT_project\2017_11Nov_3rd
load('/home/rxg243/Dropbox/TEMP/data_subj_19_PCM_rg_20171103.mat')

sub = 1;
 
Y = PCM_data{1,5};
data{sub} = Y(1:114,:);
partVec{sub} = partitionVec(1:114);
condVec{sub} = conditionVec(1:114);
CondNames = CondNames(1:6);
% 
% save data.mat data
% save partVec.mat partVec
% save condVec.mat condVec
% save CondNames.mat CondNames
% 
% Load V3 data

% load data
% load partVec.mat partVec
% load condVec.mat condVec
% load CondNames.mat CondNames

% partitionVec(conditionVec>6)=0
% 
% conditionVec(conditionVec>6)=0
% 
% 
% condVec{1} = conditionVec
% partVec{1} = partitionVec
% data{1} = PCM_data{4};



figure
clims = [4 18];
% Compute empirical G - without mean subtraction
Z=pcm_indicatorMatrix('identity',condVec{sub});
b = pinv(Z)*data{sub};           % Estimate mean activities
G_empirical_withmean=cov(b');
subplot(1,5,1); imagesc(G_empirical_withmean); colorbar;

% Compute empirical G - with subtracting mean for each condition across run
Z=pcm_indicatorMatrix('identity',condVec{sub});
b = pinv(Z)*data{sub};           % Estimate mean activities
b(1:6,:)  = bsxfun(@minus,b(1:6,:) ,mean(b(1:6,:))); % Subtract mean per hand
G_empirical=cov(b');
subplot(1,5,2); imagesc(G_empirical);colorbar;


% Compute crossvalidated G
G_hat_crossval=pcm_estGCrossval(data{sub},partVec{sub},condVec{sub});
H = eye(6)-ones(6)/6; % Centering matrix
subplot(1,5,3); imagesc(H*G_hat_crossval*H');colorbar;



% 
runEffect  = 'fixed';

% % Free model by hand
% M{1}.type       = 'feature';
% M{1}.numGparams = 21;
% M{1}.name       = 'freebyhand';
% for i=1:6
%     A=zeros(6,21);
%     A(i,i)=1;
%     M{1}.Ac(:,:,i)    = A;  
% end
% 
% for i = 1:5
%     A=zeros(6,21);
%     A(i+1,1) = 1;
%     M{1}.Ac(:,:,i+6)    = A;  
% end
% 
% for i = 1:4
%     A=zeros(6,21);
%     A(i+2,2) = 1;
%     M{1}.Ac(:,:,i+11)    = A;  
% end
% 
% for i = 1:3
%     A=zeros(6,21);
%     A(i+3,3) = 1;
%     M{1}.Ac(:,:,i+15)    = A;  
% end
% 
% for i = 1:2
%     A=zeros(6,21);
%     A(i+4,4) = 1;
%     M{1}.Ac(:,:,i+18)    = A;  
% end
% 
% for i = 1:1
%     A=zeros(6,21);
%     A(i+5,5) = 1;
%     M{1}.Ac(:,:,i+20)    = A;  
% end
% M{1}.theta0=ones(21,1);                        % Starting values: could be closer, but converges anyways 
% M{1}.fitAlgorithm = 'minimize';
% [D,theta,G_hat] = pcm_fitModelIndivid(data,M,partVec,condVec,'runEffect',runEffect);
% subplot(1,5,4); imagesc(G_hat{1});colorbar;
% subplot(1,5,5); imagesc(H*G_hat{1}*H');colorbar;




% % Free model as Noise ceiling - non-crossvalidated
 
M{1}.type       = 'freechol';
M{1}.numCond    = 6;
M{1}.name       = 'noiseceiling';
M{1}           = pcm_prepFreeModel(M{1});
M{1}.fitAlgorithm = 'minimize';
[D,theta,G_hat] = pcm_fitModelIndivid(data,M,partVec,condVec,'runEffect',runEffect);
subplot(1,5,5); imagesc(H*G_hat{1}*H');colorbar;
ColorMap = brain_colour_maps('hot_increasing');
colormap(ColorMap)
 
 
 
% % % Free model as Noise ceiling - crossvalidated
% % runEffect  = 'fixed';
% % 
% % M{1}.type       = 'freechol';
% % M{1}.numCond    = 6;
% % M{1}.name       = 'noiseceiling';
% % M{1}           = pcm_prepFreeModel(M{1});
% % M{1}.fitAlgorithm = 'minimize';
% % 
% % [D2,theta2,G_hat2] = pcm_fitModelIndividCrossval(data,M,partVec,condVec,'runEffect',runEffect);
% % 
% % subplot(2,4,5); imagesc(G_hat2{1});colorbar;


load('/home/rxg243/Dropbox/PhD/Experiments/AVT/derivatives/results/PCM/vol/PCM_features_stim_wht-betas_V3_thres_ROI_2017_11_03_12_50.mat', ...
    'G_pred_ind')

figure(2)
colormap(ColorMap)
subplot(1,2,1); imagesc(G_hat{1});colorbar; axis square
colormap(ColorMap)
subplot(1,2,2); imagesc(G_pred_ind{end}(:,:,end));colorbar; axis square
