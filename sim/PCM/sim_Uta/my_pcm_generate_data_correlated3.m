clear all; 
% close all

%--------------------------------------------------------------------------
% Generate data

% Define M_h matrices
% using Model2: Model with a flexible correlation for each finger 
num_conds = 10;
for i=1:5
    A=zeros(5);
    A(i,i)=1;
    Ac(:,1:5 ,i)    = [A;zeros(5)];       % Contralateral finger patterns   (theta_a)
    Ac(:,1:5 ,5+i)  = [zeros(5);A];       % Mirrored Contralateralpatterns  (theta_b)
    Ac(:,6:10,10+i) = [zeros(5);A];       % Unique Ipsilateral pattterns    (theta_c)
end
Ac(:,11  ,16)  = [ones(5,1);zeros(5,1)];  % Hand-specific component contra  (theta_d)
Ac(:,12  ,17)  = [zeros(5,1);ones(5,1)];  % Hand-specific component ipsi    (theta_e)

theta_orig = [1 2 1 -1  1 2 4 5 6 1 1 2 2 4 5 7 2];

% Define M matrix and original G matrix
M = zeros(10,12);
for i = 1 :17
    M = M + theta_orig(i)*Ac(:,:,i);
end

G_orig = M*M';
figure; subplot(1,4,1); imagesc(M);colorbar; subplot(1,4,2); imagesc(G_orig); colorbar;

% Generate activation profiles for each voxel
num_voxels = 1000;
num_feature = size(M,2);
W = randn(num_feature,num_voxels); %  weights for each feature and voxel
% figure; imagesc(W*W');

w_corr = 0;
if w_corr == 1
    my_w1 = randn(num_feature,num_voxels/2); my_w2 = ones(num_feature,500);
    W = [my_w1 my_w2];
%     W = repmat([my_w1 my_w1]',1,num_feature)';
end

U = M*W;  % U(num_conds,num_vox)
subplot(1,4,3);imagesc(U*U');colorbar % approx. = G_orig because UU' = MWW'M' = MM' if W iid

% Generate data
num_partitions = 20; 
condition_vec = kron(ones(num_partitions,1), [1:num_conds]');
partition_vec = kron([1:num_partitions]', ones(num_conds,1));
Z = repmat(eye(num_conds),num_partitions,1);%figure;imagesc(Z);
X = kron(eye(num_partitions), ones(num_conds,1));%figure;imagesc(X);
B = randn(num_partitions,num_voxels);

% generate B that are correlated over (partitions - not sure that's useful) and voxels

my_corr_part = 1; my_corr1 = 0; spat_smooth = 100;
if my_corr_part == 1
    B_init = repmat([1:20+my_corr1]',1,num_voxels+spat_smooth); % mean activation increases over runs
    B_more = B_init+randn(num_partitions+my_corr1,num_voxels+spat_smooth);
    for i = 1 : size(B,1)
        B1(i,:) = mean(B_more(i:i+my_corr1,:),1);
    end
    for i = 1 : size(B,2)
        B(:,i) = mean(B1(:,i:i+spat_smooth),2); % mean effects are correlated over voxels
    end
    
end


S = 5; % NxN temporal cov matrix; here iid; i.e. S = scalar
e = S*randn(num_conds*num_partitions,num_voxels);

my_corr_e = 1; S2=10;  % positively correlated error within a run
e_spat_smooth = 100;

if my_corr_e == 1
    part_e = randn(num_partitions,num_voxels+e_spat_smooth)*S2;
    for i = 1 : num_partitions
        for k = 1 : num_voxels+e_spat_smooth
            e1((i-1)*num_conds+1:i*num_conds, k) = repmat(part_e(i,k),num_conds,1)+randn(num_conds,1)*S;
        end
    end
    for i = 1 : num_voxels
        e(:,i) = mean(e1(:,i:i+spat_smooth),2); % errors are correlated over voxels
    end

end
% figure;imagesc(e)

    

Y = Z*U + X*B + e; 
% subplot(1,2,1);imagesc(Y);
subplot(1,4,4);imagesc(Y*Y');

% save data in format
sub = 1;
data{sub} = Y;
partVec{sub} = partition_vec;
condVec{sub} = condition_vec;

save hokus.mat data partVec condVec U G_orig 
% 
% 
% 
% 
% % load data_recipe_correlation.mat
% runEffect  = 'fixed';
% alg = 'minimize'; 
% 
% % % --------------------------------------
% % % Model1: Model with independent contra and ipsilateral patterns (zero
% % % correlation)
% % M{1}.type       = 'feature';
% % M{1}.numGparams = 12;
% % for i=1:5
% %     A=zeros(5);
% %     A(i,i)=1;
% %     M{1}.Ac(:,1:5 ,i)    = [A;zeros(5)];       % Contralateral finger patterns   (theta_a)
% %     M{1}.Ac(:,6:10,5+i) = [zeros(5);A];        % Unique Ipsilateral pattterns    (theta_c)
% %     M{1}.name       = 'null';
% % end
% % M{1}.Ac(:,11  ,11)  = [ones(5,1);zeros(5,1)];  % Hand-specific component contra  (theta_d)
% % M{1}.Ac(:,12  ,12)  = [zeros(5,1);ones(5,1)];  % Hand-specific component ipsi    (theta_e)
% % M{1}.theta0=ones(12,1);                        % Starting values: could be closer, but converges anyways 
% % M{1}.fitAlgorithm = alg; 
% % 
% % % --------------------------------------
% % 
% % % --------------------------------------
% % % Model3: Model with a fixed r=1 correlation (ipsilateral = scaled version of contralateral pattern) 
% % M{3}.type       = 'feature';
% % M{3}.numGparams = 12;
% % for i=1:5
% %     A=zeros(5);
% %     A(i,i)=1;
% %     M{3}.Ac(:,1:5 ,i)    = [A;zeros(5)]; % Contralateral finger patterns   (theta_a)
% %     M{3}.Ac(:,1:5 ,5+i)  = [zeros(5);A]; % Mirrored Contralateralpatterns  (theta_b)
% %     M{3}.name       = 'one';
% % end
% % M{3}.Ac(:,6,11)  = [ones(5,1);zeros(5,1)]; % Hand-specific component contra  (theta_d)
% % M{3}.Ac(:,7,12)  = [zeros(5,1);ones(5,1)]; % Hand-specific component ipsi    (theta_e)
% % M{3}.theta0=ones(12,1);
% % M{3}.fitAlgorithm = alg; 
% 
% % Free model as Noise ceiling
% M{1}.type       = 'freechol'; 
% M{1}.numCond    = 10;
% M{1}.name       = 'noiseceiling'; 
% M{1}           = pcm_prepFreeModel(M{1}); 
% 
% 
% %%
% for p=1:12
%     G_emp(:,:,p)=pcm_estGCrossval(Data{p},partVec{p},condVec{p});
% end
% 
% 
% %%
% [T_ind,theta_ind,G_pred_ind] = pcm_fitModelIndivid(Data,M,partVec,condVec,'runEffect',runEffect);
% [D,T_ind_cv,theta_ind_cv]=pcm_fitModelIndividCrossval(Data,M,partVec,condVec,'runEffect',runEffect);
% 
% % generate the predicted matrices for ind CV
% for iM = 1:numel(M)
%     for p = 1:12
%         tmp = mean(theta_ind_cv{iM}(T_ind_cv.SN==p,:),1);
%         G_pred_ind_cv{iM}(:,:,p) = pcm_calculateG(M{iM},tmp(1:M{iM}.numGparams)'); %#ok<SAGROW>
%         clear tmp
%     end
% end
% 
% %%
% figure('name', 'G_{pred}-ind')
% i=1;
% H = eye(10)-ones(10)/10;
% for p=1:12
%     subplot(3,12,i)
%     imagesc(H*G_emp(:,:,p)*H')
%     i=i+1;
%     axis square
%     colorbar
% end
% for p=1:12
%     subplot(3,12,i)
%     imagesc(G_pred_ind{1}(:,:,p))
%     axis square
%     colorbar
%     i=i+1;
% end
% for p=1:12
%     subplot(3,12,i)
%     imagesc(G_pred_ind_cv{1}(:,:,p))
%     axis square
%     colorbar
%     i=i+1;
% end
% subplot(3,12,1);
% ylabel('CVed G_{emp}')
% subplot(3,12,13);
% ylabel('G_{free}-ind')
% subplot(3,12,25);
% ylabel('G_{free}-ind-CV')
% 
% % 
% % %% Now do crossvalidated model comparision: 
% % [T_gr,theta_gr,G_pred_gr] = pcm_fitModelGroup(Data,M,partVec,condVec,'runEffect',...
% %     runEffect,'fitScale',1);
% % [T_gr_cv,theta_gr_cv,G_pred_gr_cv] = pcm_fitModelGroupCrossval(Data,M,partVec,...
% %     condVec,'runEffect',runEffect,'groupFit',theta_gr,'fitScale',1);
% % 
% % 
% % 
% % %%
% % figure('name', 'G_{pred}-grp')
% % i=1;
% % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/numel(size(M{1}.Ac,1));
% % 
% % subplot(1,3,1)
% % imagesc(H*mean(G_emp,3)*H')
% % axis square
% % title('CVed G_{emp}-gr')
% % 
% % subplot(1,3,2)
% % imagesc(G_pred_gr{end})
% % axis square
% % title('G_{free}-gr')
% % 
% % subplot(1,3,3)
% % imagesc(mean(G_pred_gr_cv{end},3))
% % axis square
% % title('G_{free}-gr-CV')
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% 
