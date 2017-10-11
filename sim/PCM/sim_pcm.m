% Simulated data dataset for PCM
% Remi Gau adapted from Johanna Zumer, 2017

clc; clear; close all

StartDir = fullfile(pwd, '..','..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')

NbFeatures = 1000;
NbCdt = 6;
NbSess = 20;
NbSubj = 10;

MaxIteration = 50000;

% Model:      Y=Z*U + X*B + E;
Z=zeros(NbSess,NbCdt); % assume 6 conditions with 20 examplars per condition, same for all subjects
Z(1:NbSess,1)=1;
Z(1+NbSess*1:NbSess*2,2)=1;
Z(1+NbSess*2:NbSess*3,3)=1;
Z(1+NbSess*3:NbSess*4,4)=1;
Z(1+NbSess*4:NbSess*5,5)=1;
Z(1+NbSess*5:NbSess*6,6)=1;

% condition means added
% for auditory ROI
meanadd=[...
    5*ones(NbSess,NbFeatures); ... A contra
    5*ones(NbSess,NbFeatures); ... A ipsi
    ones(NbSess,NbFeatures); ... V Contra
    ones(NbSess,NbFeatures); ... V Ipsi
    2*ones(NbSess,NbFeatures); ... T contra
    2*ones(NbSess,NbFeatures)]; % T ipsi

% noise level added
% sigmodel=[1 5 10];
sigmodel=1;

%% get the pattern components
% '1-Null'
% '2-Sensory modalities'
% '3-A stim'
% '4-V stim'
% '5-T stim'
% '6-Non Preferred_A'
% '7-Non Preferred_V'
% '8-Ipsi Contra'
% '9-Ipsi Contra_{VT}'
% '10-Ipsi Contra_{AT}'
% '11-Ipsi Contra_{AV}'
[Components] = Set_PCM_components(0);


%% get the typical models
[Models_A, Models_V] = Set_PCM_models(Components, 0);

Models = Models_A;

M = {};

colors={'b'};

% null model
M{1}.type       = 'component';
M{1}.numGparams = 1;
M{1}.Gc         = eye(NbCdt);
M{1}.name       = 'null';

% add each model
for iMod=1:numel(Models)
    
    M{end+1}.type       = 'component';
    
    M{end}.numGparams = numel(Models(iMod).Cpts);
    
    M{end}.Gc         = cat(3,Components(Models(iMod).Cpts).G);
    
    tmp = strrep(num2str(Models(iMod).Cpts),'  ', ' ');
    tmp = strrep(tmp,'  ', ' ');
    M{end}.name       = strrep(tmp,' ', '+'); clear tmp
    
    colors{end+1}='b';
    
end

% Free model as Noise ceiling
M{end+1}.type       = 'freechol';
M{end}.numCond    = NbCdt;
M{end}.name       = 'noiseceiling';
M{end}           = pcm_prepFreeModel(M{end});


%% simulated model weights.
% order of G:
% '1-Null'
% '2-Sensory modalities'
% '3-A stim'
% '4-V stim'
% '5-T stim'
% '6-Non Preferred_A'
% '7-Non Preferred_V'
% '8-Ipsi Contra'
% '9-Ipsi Contra_{VT}'
% '10-Ipsi Contra_{AT}'
% '11-Ipsi Contra_{AV}'

theta_real = ones(numel(Models_A),numel(Components))*-inf;
for iMod=1:numel(Models_A)
    theta_real(iMod,(Models_A(iMod).Cpts)) = 0;
end

% Creates G_sum 
% Gtotal = SUM_ii [exp(theta_ii)*G_ii]
for tr=1:size(theta_real,1)
    
    tmp = exp(theta_real(tr,1))*Components(1).mat;
    
    for iG = 2:size(theta_real,2)
        tmp = tmp + exp(theta_real(tr,iG))*Components(iG).G;
    end
    
    G_sum(:,:,tr) = tmp; %#ok<*SAGROW>

end

% Get a G matrix for other participants with only component 2
G_null = Components(1).G;

%% % Generate data
% Activation U different for every subject, but same pattern.
% Take in to account modelling noise
for ss=1:NbSubj  % pretend 10 subjects

    % Generate multivariate distributions
    for tr=1:size(theta_real,1)
        
        MScon{tr}=mvnrnd(zeros(1,NbCdt),G_sum(:,:,tr),NbFeatures)';
        
        Y_ms{tr}=Z*MScon{tr};
        
        for sm=1:length(sigmodel)
            % add noise
            Y_ms_n{tr,sm}{ss}=Y_ms{tr}+sigmodel(sm)*demean(randn(NbSess*NbCdt,NbFeatures),2);
            % add mean
            Y_ms_n_mc{tr,sm}{ss}=Y_ms_n{tr,sm}{ss}+meanadd;
        end
    end
    
end % ss

% generate 2 more subjects with no pattern
% for ss=1:3  
% 
%     % Generate multivariate distributions
%     for tr=1:size(theta_real,1)
%         
%         MScon{tr}=mvnrnd(zeros(1,NbCdt),G_null,NbFeatures)';
%         
%         Y_ms{tr}=Z*MScon{tr};
%         
%         for sm=1:length(sigmodel)
%             % add noise
%             Y_ms_n{tr,sm}{end+1}=Y_ms{tr}+sigmodel(sm)*demean(randn(NbSess*NbCdt,NbFeatures),2);
%             % add mean
%             Y_ms_n_mc{tr,sm}{end+1}=Y_ms_n{tr,sm}{end}+meanadd;
%         end
%     end
%     
% end % ss


%% Fit the models on the group level

partVec = repmat((1:NbSess)',[NbCdt 1]);
condVec = repmat((1:NbCdt),[NbSess 1]);
condVec = condVec(:);

% [KillGcpOnExit] = OpenParWorkersPool(4);

fprintf('\n\n\nRunning simulation on demeaned data.\n')
for sm=1:length(sigmodel)
    fprintf('\n\n\n Running on noise level %i.\n', sm)
    fprintf('\n\n\n  Running with no CV.\n')
    for tr=1:length(MScon)
        [ms_mr{tr,sm}.Tgroup,ms_mr{tr,sm}.theta,ms_mr{tr,sm}.G_pred] = ...
            pcm_fitModelGroup(Y_ms_n{tr,sm},M,partVec,condVec,'runEffect','fixed','fitScale',1);
    end
    save(fullfile(pwd, sprintf('sim_pcm_output_cv_demean_noise_%i.mat', sm)),'ms_mr');

    fprintf('\n\n\n  Running with CV\n')
    for tr=1:length(MScon)
            [ms_mr{tr,sm}.Tcross,ms_mr{tr,sm}.thetaCr,ms_mr{tr,sm}.G_predcv] = ...
            pcm_fitModelGroupCrossval(Y_ms_n{tr,sm},M,partVec,condVec,'runEffect','fixed',...\
            'groupFit',ms_mr{tr,sm}.theta,'fitScale',1, 'MaxIteration', MaxIteration);
    end
    save(fullfile(pwd, sprintf('sim_pcm_output_cv_demean_noise_%i.mat', sm)),'ms_mr');
end


% multisensory, mean condition included
fprintf('\n\n\nRunning simulation on data with mean.\n')
for sm=1:length(sigmodel)
    fprintf('\n\n\n Running on noise level %i.\n', sm)
    fprintf('\n\n\n  Running with no CV.\n')
    for tr=1:length(MScon)
        [ms_mc{tr,sm}.Tgroup,ms_mc{tr,sm}.theta,ms_mc{tr,sm}.G_pred] = ...
            pcm_fitModelGroup(Y_ms_n_mc{tr,sm},M,partVec,condVec,'runEffect','fixed','fitScale',1);
    end
    save(fullfile(pwd, sprintf('sim_pcm_output_cv_noise_%i.mat', sm)),'ms_mc');
    
    fprintf('\n\n\n  Running with CV.\n')
    for tr=1:length(MScon)        
        [ms_mc{tr,sm}.Tcross,ms_mc{tr,sm}.thetaCr,ms_mc{tr,sm}.G_predcv] = ...
            pcm_fitModelGroupCrossval(Y_ms_n_mc{tr,sm},M,partVec,condVec,'runEffect','fixed',...
            'groupFit',ms_mc{tr,sm}.theta,'fitScale',1, 'MaxIteration', MaxIteration);
    end
    save(fullfile(pwd, sprintf('sim_pcm_output_cv_noise_%i.mat', sm)),'ms_mc');
end

