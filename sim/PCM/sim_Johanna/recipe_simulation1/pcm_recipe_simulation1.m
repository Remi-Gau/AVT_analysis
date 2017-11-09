% Simulated data for PCM based on EEG study with 64 channels and 7
% audio-tactile asynchronies
%
% Johanna Zumer and Remi Gau, 2017

% Modify for your location
% addpath('D:\Matlab\pcm_toolbox\')
addpath('/home/rxg243/Dropbox/GitHub/pcm_toolbox')
addpath('/home/rxg243/Dropbox/GitHub/rsatoolbox')

%%
% Model:      Y=Z*U + X*B + E;

ncond=7;
plotflag=1;
sim1_RDM_G

Z=zeros(350,7); % assume 7 conditions with 50 trials per condition, same for all subjects
Z(1:50,1)=1;
Z(51:100,2)=1;
Z(101:150,3)=1;
Z(151:200,4)=1;
Z(201:250,5)=1;
Z(251:300,6)=1;
Z(301:350,7)=1;


% Activation U different for every subject, but same pattern.
for ss=1:22  % 22 subjects
    % simulated model weights.  Gtotal = SUM_ii [exp(theta_ii)*G_ii]
    
    % 10 different models (of varying weights between 4 component G_ii)
    % order of G_ii:  eye, TIW, Asymm, Sym_pair
    % These here are same for each subject but could in future modify to vary
    % per subject to test group-CV
    theta_real(1,:) = [0 -inf -inf -inf];
    theta_real(2,:) = [-inf 0 -inf -inf];
    theta_real(3,:) = [-inf -inf 0 -inf];
    theta_real(4,:) = [-inf -inf -inf 0];
    
    theta_real(5,:) = [0 0 -inf -inf];
    theta_real(6,:) = [-inf -inf 0 0 ];
    theta_real(7,:) = [-inf 0 0 -inf];
    
    theta_real(8,:) = [0 0 0 -inf];
    theta_real(9,:) = [0 2 0 -inf];
    theta_real(10,:) = [0 0 0 0];
    
    % X*B is condition mean
    X=Z;
    B=[1; 1.2; 1.4; 1.6; 1.4; 1.2; 1];
    
    % Average scaling factor (first column) and noise level (second column) for the G matrix
    Scale_noise=[100 1;   10 1;    1 1;    0.1 1];
    
    
    for tr=1:size(theta_real,1)
        G_sum(:,:,tr) = exp(theta_real(tr,1))*G_eye + exp(theta_real(tr,2))*G_1a + exp(theta_real(2))*G_1b + exp(theta_real(tr,3))*G_2a + exp(theta_real(tr,4))*G_3a;
        
        for sm=1:size(Scale_noise,1)
            % Generate scaling factor for each subject (distributed around group mean)
            % take absolute values to make sure we get positive matrices in the end
            theta_s(sm,ss)   = abs(Scale_noise(sm,1)+randn*.1);
            theta_sig(sm,ss) = abs(Scale_noise(sm,2)+randn*.1);
            
            V = Z*G_sum(:,:,tr)*theta_s(sm,ss)*Z';
            V = V + eye(size(V))*theta_sig(sm,ss);
            
            Y_ms_n{tr,sm}{ss}   =mvnrnd(zeros(1,350),V,64)';
            Y_ms_n_mc{tr,sm}{ss}=mvnrnd(X*B,         V,64)';
        end
    end
    
end % ss


% Set .fitAlgorithm = 'minimize' or 'NR' inside this script
try
    load('pcm_models.mat');  % from create_sim1models
catch
    create_sim1models
end

%%
close all
% Fit the models on the group level
% Still playing around with how best to partition for cross-validation
% partVec=repmat([1 2],[1 175])';
partVec=repmat([1 2 3 4 5],[1 70])';

try
    load('sim1_pcm_output.mat')
catch % this will generate the results saved into sim1_pcm_output.mat
    
    % This takes a long time to run with 'minimize'
    % Slightly faster with 'NR' but then crashes
    %   for sm=1:size(Y_ms_n,2)
    %     for tr=1:size(Y_ms_n,1)
    for sm=1:2
        for tr=1:2
            % condition means removed
            [ms_mr{tr,sm}.Tgroup, ms_mr{tr,sm}.theta, ms_mr{tr,sm}.G_pred] = pcm_fitModelGroup(Y_ms_n{tr,sm},M,partVec,Z,'runEffect','fixed','fitScale',1);
            [ms_mr{tr,sm}.Tcross, ms_mr{tr,sm}.thetaCr, ms_mr{tr,sm}.G_predcv] = pcm_fitModelGroupCrossval(Y_ms_n{tr,sm},M,partVec,Z,'runEffect','fixed','groupFit',ms_mr{tr,sm}.theta,'fitScale',1);
            save('sim1_pcm_output.mat','ms_mr','partVec','M');
        end
    end
    
    %   for sm=1:size(Y_ms_n,2)
    %     for tr=1:size(Y_ms_n,1)
    for sm=1:2
        for tr=1:2
            % condition means included
            [ms_mc{tr,sm}.Tgroup, ms_mc{tr,sm}.theta, ms_mc{tr,sm}.G_pred] = pcm_fitModelGroup(Y_ms_n_mc{tr,sm},M,partVec,Z,'runEffect','fixed','fitScale',1);
            [ms_mc{tr,sm}.Tcross, ms_mc{tr,sm}.thetaCr, ms_mc{tr,sm}.G_predcv] = pcm_fitModelGroupCrossval(Y_ms_n_mc{tr,sm},M,partVec,Z,'runEffect','fixed','groupFit',ms_mc{tr,sm}.theta,'fitScale',1);
            save('sim1_pcm_output.mat','ms_mr','ms_mc','partVec','M');
        end
    end
end

%%
set_pcmsim1_colors
close all
for tr=1:2%size(Y_ms_n,1)
    Nnull=17;
    Nceil=2;
    colors{tr}(Nnull)=[];
    colors{tr}(Nceil)=[];
    for sm=1:2 %size(Y_ms_n,2)
        figure(tr)
        subplot(4,2,2*(sm-1)+1);
        ms_mr{tr,sm}.T = pcm_plotModelLikelihood(ms_mr{tr,sm}.Tcross,M,'upperceil',ms_mr{tr,sm}.Tgroup.likelihood(:,2),'normalize',0,'Nnull',Nnull,'Nceil',Nceil,'colors',colors{tr});
        if sm==1,title('CV');end
        subplot(4,2,2*(sm-1)+2);
        ms_mr{tr,sm}.T = pcm_plotModelLikelihood(ms_mr{tr,sm}.Tgroup,M,'upperceil',ms_mr{tr,sm}.Tgroup.likelihood(:,2),'normalize',0,'Nnull',Nnull,'Nceil',Nceil,'colors',colors{tr});
        if sm==1,title('non-CV');end
    end
end



