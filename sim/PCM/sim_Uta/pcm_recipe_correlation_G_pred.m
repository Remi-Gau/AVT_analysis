clear all
load hokus.mat
% load data_recipe_correlation.mat
% data = Data(1)
sub =1;
runEffect  = 'fixed';
alg = 'minimize'; 

% --------------------------------------
% Model1: Model with independent contra and ipsilateral patterns (zero
% correlation)
% M{1}.type       = 'feature';
% M{1}.numGparams = 12;
% for i=1:5
%     A=zeros(5);
%     A(i,i)=1;
%     M{1}.Ac(:,1:5 ,i)    = [A;zeros(5)];       % Contralateral finger patterns   (theta_a)
%     M{1}.Ac(:,6:10,5+i) = [zeros(5);A];        % Unique Ipsilateral pattterns    (theta_c)
%     M{1}.name       = 'null';
% end
% M{1}.Ac(:,11  ,11)  = [ones(5,1);zeros(5,1)];  % Hand-specific component contra  (theta_d)
% M{1}.Ac(:,12  ,12)  = [zeros(5,1);ones(5,1)];  % Hand-specific component ipsi    (theta_e)
% M{1}.theta0=ones(12,1);                        % Starting values: could be closer, but converges anyways 
% M{1}.fitAlgorithm = alg; 
% 
% % --------------------------------------
% % Model2: Model with a flexible correlation for each finger 
% M{2}.type       = 'feature';
% M{2}.numGparams = 17;
% for i=1:5
%     A=zeros(5);
%     A(i,i)=1;
%     M{2}.Ac(:,1:5 ,i)    = [A;zeros(5)];       % Contralateral finger patterns   (theta_a)
%     M{2}.Ac(:,1:5 ,5+i)  = [zeros(5);A];       % Mirrored Contralateralpatterns  (theta_b)
%     M{2}.Ac(:,6:10,10+i) = [zeros(5);A];       % Unique Ipsilateral pattterns    (theta_c)
%     M{2}.name       = 'flex';
% end
% M{2}.Ac(:,11  ,16)  = [ones(5,1);zeros(5,1)];  % Hand-specific component contra  (theta_d)
% M{2}.Ac(:,12  ,17)  = [zeros(5,1);ones(5,1)];  % Hand-specific component ipsi    (theta_e)
% M{2}.theta0=ones(17,1);
% M{2}.fitAlgorithm = alg; 
% 
% % --------------------------------------
% % Model3: Model with a fixed r=1 correlation (ipsilateral = scaled version of contralateral pattern) 
% M{3}.type       = 'feature';
% M{3}.numGparams = 12;
% for i=1:5
%     A=zeros(5);
%     A(i,i)=1;
%     M{3}.Ac(:,1:5 ,i)    = [A;zeros(5)]; % Contralateral finger patterns   (theta_a)
%     M{3}.Ac(:,1:5 ,5+i)  = [zeros(5);A]; % Mirrored Contralateralpatterns  (theta_b)
%     M{3}.name       = 'one';
% end
% M{3}.Ac(:,6,11)  = [ones(5,1);zeros(5,1)]; % Hand-specific component contra  (theta_d)
% M{3}.Ac(:,7,12)  = [zeros(5,1);ones(5,1)]; % Hand-specific component ipsi    (theta_e)
% M{3}.theta0=ones(12,1);
% M{3}.fitAlgorithm = alg; 

% Free model as Noise ceiling
M{1}.type       = 'freechol'; 
M{1}.numCond    = 10;
M{1}.name       = 'noiseceiling'; 
M{1}           = pcm_prepFreeModel(M{1}); 




%--------------------------------------------------------------------------
figure; num_fig = 6;

H = eye(10)-ones(10)/10;


% Compute empirical G - without mean subtraction
Z=pcm_indicatorMatrix('identity',condVec{sub});
b = pinv(Z)*data{sub};           % Estimate mean activities
G_empirical_withmean=cov(b');
subplot(1,num_fig,1); imagesc(G_empirical_withmean); colorbar;
subplot(1,num_fig,2);imagesc(H*G_empirical_withmean*H'); colorbar;


%%
for p=sub
    G_emp(:,:,p)=pcm_estGCrossval(data{p},partVec{p},condVec{p});
end
subplot(1,num_fig,3); imagesc(G_emp);colorbar;
subplot(1,num_fig,4); imagesc(H*G_emp*H');colorbar;

%%
[T_ind,theta_ind,G_pred_ind] = pcm_fitModelIndivid(data,M,partVec,condVec,'runEffect',runEffect);
subplot(1,num_fig,5); imagesc(G_pred_ind{1});colorbar;
subplot(1,num_fig,6); imagesc(H*G_pred_ind{1}*H');colorbar;

% 
% 
% [D,T_ind_cv,theta_ind_cv]=pcm_fitModelIndividCrossval(data,M,partVec,condVec,'runEffect',runEffect);
% 
% % generate the predicted matrices for ind CV
% for iM = 1:numel(M)
%     for p = 1:sub
%         tmp = mean(theta_ind_cv{iM}(T_ind_cv.SN==p,:),1);
%         G_pred_ind_cv{iM}(:,:,p) = pcm_calculateG(M{iM},tmp(1:M{iM}.numGparams)'); %#ok<SAGROW>
%         clear tmp
%     end
% end
% 
% %%
% figure('name', 'G_{pred}-ind')
% num_sub = 1;
% i=1;
% H = eye(10)-ones(10)/10;
% for p=1:num_sub
%     subplot(3,12,i)
%     imagesc(H*G_emp(:,:,p)*H')
%     i=i+1;
%     axis square
% end
% for p=1:num_sub
%     subplot(3,12,i)
%     imagesc(G_pred_ind{end}(:,:,p))
%     axis square
%     i=i+1;
% end
% for p=1:num_sub
%     subplot(3,12,i)
%     imagesc(G_pred_ind_cv{end}(:,:,p))
%     axis square
%     i=i+1;
% end
% subplot(3,12,1);
% ylabel('CVed G_{emp}')
% subplot(3,12,13);
% ylabel('G_{free}-ind')
% subplot(3,12,25);
% ylabel('G_{free}-ind-CV')
% 
% 
% %% Now do crossvalidated model comparision: 
% [T_gr,theta_gr,G_pred_gr] = pcm_fitModelGroup(data,M,partVec,condVec,'runEffect',...
%     runEffect,'fitScale',1);
% [T_gr_cv,theta_gr_cv,G_pred_gr_cv] = pcm_fitModelGroupCrossval(data,M,partVec,...
%     condVec,'runEffect',runEffect,'groupFit',theta_gr,'fitScale',1);
% 
% 
% 
% %%
% figure('name', 'G_{pred}-grp')
% i=1;
% H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/numel(size(M{1}.Ac,1));
% 
% subplot(1,3,1)
% imagesc(H*mean(G_emp,3)*H')
% axis square
% title('CVed G_{emp}-gr')
% 
% subplot(1,3,2)
% imagesc(G_pred_gr{end})
% axis square
% title('G_{free}-gr')
% 
% subplot(1,3,3)
% imagesc(mean(G_pred_gr_cv{end},3))
% axis square
% title('G_{free}-gr-CV')
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
