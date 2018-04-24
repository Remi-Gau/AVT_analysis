%% Simulated "scaled" dataset for PCM
% Remi Gau - 2018-04-18

clc; clear; close all

StartDir = fullfile(pwd, '..','..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

Save_dir = fullfile(StartDir, 'results', 'sim', 'PCM');
Fig_dir = fullfile(StartDir, 'figures', 'sim', 'PCM');

numSim = 50;
NbVox = 500;
NbSess = 20;
NbSteps = 21;


%% Define models
% Scaled
Model{1}.type       = 'feature';
Model{end}.Ac = [1 0]';
Model{end}.Ac(:,1,2) = [0 1]';
Model{end}.name       = 'Scaled';
Model{end}.numGparams = size(Model{end}.Ac,3);
Model{end}.fitAlgorithm = 'NR';

% Scaled and independent
Model{end+1}.type       = 'feature';
Model{end}.Ac = [1 0]';
Model{end}.Ac(:,1,2) = [0 1]';
Model{end}.Ac(:,2,3) = [0 1]';
Model{end}.name       = 'Scaled+Independent';
Model{end}.numGparams = size(Model{end}.Ac,3);
Model{end}.fitAlgorithm = 'NR';

% Independent
Model{end+1}.type       = 'feature';
Model{end}.Ac = [1 0]';
Model{end}.Ac(:,2,2) = [0 1]';
Model{end}.name       = 'Independent';
Model{end}.numGparams = size(Model{end}.Ac,3);
Model{end}.fitAlgorithm = 'NR';


%% Set values
%   theta:   numParams x 1 vector of parameters for Model
theta = [linspace(1,2,NbSteps)' ones(NbSteps,1)];

%   signal:  Signal variance: scalar, <numSim x 1>, <1xnumVox>, or <numSim x numVox>
%   noise:   Noise  variance: scalar, <numSim x 1>, <1xnumVox>, or <numSim x numVox>
signal = ones(numSim,1)+randn(numSim,1);%rand(1,NbVox);
noise = 1.5;%rand(1,NbVox);

%   numSim:  number of simulations,all returned in cell array Y

%   D: Experimental structure with fields
%       D.numPart = number of partititions
%       D.numVox  = number of independent voxels
D.numPart = NbSess;
D.numVox  = NbVox;

% VARARGIN:
%   'signalDist',fcnhnd:    Functionhandle to distribution function for signal
%   'noiseDist',fcnhnd:     Functionhandle to distribution function for noise
%   'design',X:             - Design matrix (for encoding-style models)
%                           - Condition vector (for RSA-style models)
%                           Design matrix and Condition vector are assumed
%                           to be for 1 partition only.
%                           If not specified - the function assumes a
%                           RSA-style model with G being numCond x numCond
noiseDist = @(x) norminv(x,0,1);   % Standard normal inverse for Noise generation
signalDist = @(x) norminv(x,0,1);  % Standard normal inverse for Signal generation

% Design matrix
X = [1 0;0 1];


%% MVPA parameters

% Feature selection (FS)
opt.fs.threshold = 0.75;
opt.fs.type = 'ttest2';

% Recursive feature elminiation (RFE)
opt.rfe.threshold = 0.01;
opt.rfe.nreps = 20;

% SVM C/nu parameters and default arguments
opt.svm.machine = 'C-SVC';
opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';

opt.svm.dargs = [opt.svm.dargs ' -t 0 -q']; % inherent linear kernel, quiet mode

opt.fs.do = 0; % feature selection
opt.rfe.do = 0; % recursive feature elimination
opt.scaling.idpdt = 1; % scale test and training sets independently
opt.permutation.test = 0;

opt.scaling.img.eucledian = 0;
opt.scaling.feat.mean = 0;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;


SVM(1) = struct('name', 'Cst 1 VS Cdt 2', 'class', [1 2], 'ROI_2_analyse', 1);

CV_id = 1:NbSess;

sets = {1:6,1:7,1:7};
[x, y, z] = ndgrid(sets{:});
TestSessList{1,1} = [x(:) y(:) z(:)];

NbCV = size(TestSessList{1,1}, 1);


%%
% Generate data
for iTheta = 1:size(theta,1)
    
    
    [Y,partVec,condVec] = pcm_generateData(Model{1},theta(iTheta,:)',D,numSim,signal,noise,...
        'signalDist', noiseDist, 'noiseDist', signalDist, 'design', X);
    
    CV_Mat(:,1) = [condVec(:,1) + condVec(:,2)*2];
    CV_Mat(:,2) = partVec;
    
%     imagesc(Y{1})
%     
%     scatter(...
%         mean(Y{1}(logical(condVec(:,1)),:)),...
%         mean(Y{1}(logical(condVec(:,2)),:)), '.')
    
    for iSubj = 1:numSim
        
        for iCV=1:NbCV
            
            TestSess = []; %#ok<NASGU>
            TrainSess = []; %#ok<NASGU>
            
            % Separate training and test sessions
            [TestSess, TrainSess] = deal(false(size(1:NbSess)));
            
            TestSess(TestSessList{1,1}(iCV,:)) = 1; %#ok<*PFBNS>
            TrainSess(setdiff(CV_id, TestSessList{1,1}(iCV,:)) )= 1;
            
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 0;
            results = machine_SVC(SVM(1), Y{iSubj}, CV_Mat, TrainSess, TestSess, opt);
            Acc(iSubj,1,iCV,iTheta) = mean(results.pred==results.label);
            
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 0;
            results = machine_SVC(SVM(1), Y{iSubj}, CV_Mat, TrainSess, TestSess, opt);
            Acc(iSubj,2,iCV,iTheta) = mean(results.pred==results.label);
            
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 1;
            results = machine_SVC(SVM(1), Y{iSubj}, CV_Mat, TrainSess, TestSess, opt);
            Acc(iSubj,3,iCV,iTheta) = mean(results.pred==results.label);
            
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 1;
            results = machine_SVC(SVM(1), Y{iSubj}, CV_Mat, TrainSess, TestSess, opt);
            Acc(iSubj,4,iCV,iTheta) = mean(results.pred==results.label);
            
        end
    end
    
end

%%
clear iCV iSubj iTheta Y

save(fullfile(Save_dir, ['PCM_MVPA_', datestr(now, 'yyyy_mm_dd_HH_MM'), '.mat']))

%%
close all

squeeze(mean(Acc,3));
MEAN = squeeze(mean(mean(Acc,3)));
SEM = squeeze(nansem(mean(Acc,3)));

figure('Name', 'PCM_MVPA', 'Position', [100, 100, 1500, 600], 'Color', [1 1 1]);

h = errorbar(repmat((1:NbSteps)',1,4)+repmat(0:.1:.3,NbSteps,1),MEAN',SEM');
set(h(1), 'color', 'k', 'LineWidth', 1.2)
set(h(2), 'color', 'k', 'Linestyle', '--', 'LineWidth', 1.2)
set(h(3), 'color', 'b', 'LineWidth', 1.2)
set(h(4), 'color', 'b', 'Linestyle', '--', 'LineWidth', 1.2)

set(gca, 'xtick', 1:NbSteps, 'xticklabel', theta(:,1)./theta(:,2))
ax = axis;
axis([0 NbSteps+1 ax(3) ax(4)])

ylabel('accuracy')
xlabel('theta 1 / theta 2')

legend({'No scaling','Img scaling: Z-score','Feat scaling: mean centering',...
    'Img scaling: Z-score ; Feat scaling: mean centering'}, 'Location','SouthEast')

text(NbSteps-3, ax(3)+(ax(4)-ax(3))*.5,...
    sprintf(' Nb vox = %i\n Nb subj = %i\n Var_{sig} ~ N(1,1)\n Var_{noise} = 1.5', NbVox, numSim))

print(gcf, fullfile(Fig_dir, ['PCM_MVPA_' datestr(now, 'yyyy_mm_dd_HH_MM') '.tif']), '-dtiff')


