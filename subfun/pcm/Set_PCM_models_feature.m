function M = Set_PCM_models_feature

CondNames = {...
    'A ipsi','A contra',...
    'V ipsi','V contra',...
    'T ipsi','T contra'...
    };

Alg = 'NR'; %'minimize';

M = {};

% null model
M{1}.type       = 'feature';
M{1}.Ac = [];
M{1}.Ac = zeros(numel(CondNames),1);
M{1}.numGparams = size(M{1}.Ac,3);
% M{1}.theta0=ones(size(M{1}.Ac,3),1);
M{1}.name       = 'null';
M{1}.fitAlgorithm = 'minimize';


% Model 1:      All 6 conditions elicit completely distinct patterns
M{end+1}.type       = 'feature';
M{end}.Ac = [];
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,end+1,i) = A;
end;
M{end}.name       = 'Cdt';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;

% Model 2:      Modality-specific patterns (i.e. A, V and T elicit distinct patterns);
% ipsilateral and contralateral are identical
M{end+1}.type       = 'feature';
M{end}.Ac = [];
Col = [1 1 2 2 3 3];
for i=1:2:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i:i+1) = 1;
    M{end}.Ac(:,Col(i),Col(i)) = A;
end;
M{end}.name       = 'A+V+T';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;


% Model 3:      Ipsilateral is a scaled version of contralateral 
M{end+1}.type       = 'feature';
M{end}.Ac = [];
Col = [1 1 2 2 3 3];
for i=1:2:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,Col(i),i) = A;
end;
for i=2:2:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,Col(i),i) = A;
end;
M{end}.name       = 'A+V+T w/ ipsi & contra scaled';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;


% Model 4:      Ipsilateral is a mixture of distinct pattern and a scaled version of contralateral 
M{end+1}.type       = 'feature';
M{end}.Ac = [];
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,end+1,i) = A;
end;

M{end}.Ac(:,1,end+1) = [0 1 0 0 0 0];
M{end}.Ac(:,3,end+1) = [0 0 0 1 0 0];
M{end}.Ac(:,5,end+1) = [0 0 0 0 0 1];

M{end}.name       = 'Cdt w/ ipsi & contra scaled';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;


% Model 5:      4. + general ipsi vs. contra
M{end+1}.type       = 'feature';
M{end}.Ac = [];
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,end+1,i) = A;
end;

M{end}.Ac(:,1,end+1) = [0 1 0 0 0 0];
M{end}.Ac(:,3,end+1) = [0 0 0 1 0 0];
M{end}.Ac(:,5,end+1) = [0 0 0 0 0 1];

M{end}.Ac(:,end+1,end+1) = [1 0 1 0 1 0];
M{end}.Ac(:,end+1,end+1) = [0 1 0 1 0 1];

M{end}.name       = 'Cdt w/ ipsi & contra scaled +General Ipsi +General contra';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;


% Model 6:     4. + ipsi vs. contra scaled independently for each modality
M{end+1}.type       = 'feature';
M{end}.Ac = [];
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,end+1,i) = A;
end;
M{end}.Ac(:,1,end+1) = [0 1 0 0 0 0];
M{end}.Ac(:,3,end+1) = [0 0 0 1 0 0];
M{end}.Ac(:,5,end+1) = [0 0 0 0 0 1];

M{end}.Ac(:,end+1,end+1) = [1 0 0 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 1 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 0 1 0];

M{end}.Ac(:,end+1,end+1) =   [0 1 0 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 1 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 0 0 1];

M{end}.name       = 'Cdt w/ ipsi & contra scaled +Cdt spe Ipsi +Cdt spe contra';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;


% Model 7 - auditory ROIs: 6 + non-preferred signals share a pattern 
M{end+1}.type       = 'feature';
M{end}.Ac = [];
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,end+1,i) = A;
end;

M{end}.Ac(:,1,end+1) = [0 1 0 0 0 0];
M{end}.Ac(:,3,end+1) = [0 0 0 1 0 0];
M{end}.Ac(:,5,end+1) = [0 0 0 0 0 1];

M{end}.Ac(:,end+1,end+1) = [1 0 0 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 1 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 0 1 0];

M{end}.Ac(:,end+1,end+1) =   [0 1 0 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 1 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 0 0 1];

M{end}.Ac(:,end+1,end+1) =   [0 0 1 1 1 1];

M{end}.name       = 'Auditory - Cdt w/ ipsi & contra scaled +Cdt spe Ipsi +Cdt spe contra +non-preferred';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;


% Model 7 - visual ROIs: 6 + non-preferred signals share a pattern 
M{end+1}.type       = 'feature';
M{end}.Ac = [];
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,end+1,i) = A;
end;

M{end}.Ac(:,1,end+1) = [0 1 0 0 0 0];
M{end}.Ac(:,3,end+1) = [0 0 0 1 0 0];
M{end}.Ac(:,5,end+1) = [0 0 0 0 0 1];

M{end}.Ac(:,end+1,end+1) = [1 0 0 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 1 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 0 1 0];

M{end}.Ac(:,end+1,end+1) =   [0 1 0 0 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 1 0 0];
M{end}.Ac(:,end,end+1) =   [0 0 0 0 0 1];

M{end}.Ac(:,end+1,end+1) =   [1 1 0 0 1 1];

M{end}.name       = 'Visual - Cdt w/ ipsi & contra scaled +Cdt spe Ipsi +Cdt spe contra +non-preferred';
M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
M{end}.fitAlgorithm = Alg;




% Cdt +General Ipsi +General contra
% M{end+1}.type       = 'feature';
% M{end}.Ac = [];
% for i=1:numel(CondNames)
%     A = zeros(1,numel(CondNames));
%     A(i) = 1;
%     M{end}.Ac(:,end+1,i) = A;
% end
% M{end}.Ac(:,end+1,end+1) = [1 0 1 0 1 0]; %
% M{end}.Ac(:,end+1,end+1) = [0 1 0 1 0 1];
% M{end}.name       = 'Cdt+Ipsi+Contra';
% M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
% M{end}.fitAlgorithm = 'minimize';




% Cdt_{ipsi} +Cdt_{contra-Scaled} +General Ipsi +General contra
% M{end+1}.type       = 'feature';
% M{end}.Ac = [];
% Col = [1 1 2 2 3 3];
% for i=1:2:numel(CondNames)
%     A = zeros(1,numel(CondNames));
%     A(i) = 1;
%     M{end}.Ac(:,Col(i),i) = A;
% end;
% for i=2:2:numel(CondNames)
%     A = zeros(1,numel(CondNames));
%     A(i) = 1;
%     M{end}.Ac(:,Col(i),i) = A;
% end;
% M{end}.name       = 'Cdt_{ipsi} +Cdt_{contra-Scaled} +Ipsi+Contra';
% M{end}.Ac(:,end+1,end+1) = [1 0 1 0 1 0]; %
% M{end}.Ac(:,end+1,end+1) = [0 1 0 1 0 1];
% M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
% M{end}.fitAlgorithm = 'minimize';




% A +V +T +Cdt spe ispi +Cdt spe contra'
% M{end+1}.type       = 'feature';
% M{end}.Ac = [];
% Col = [1 1 2 2 3 3];
% for i=1:2:numel(CondNames)
%     A = zeros(1,numel(CondNames));
%     A(i:i+1) = 1;
%     M{end}.Ac(:,Col(i),Col(i)) = A;
% end;
% Col = [1 1 2 2 3 3];
% for i=1:2:numel(CondNames)
%     A = zeros(1,numel(CondNames));
%     A(i) = 1;
%     M{end}.Ac(:,3+Col(i),end+1) = A;
% end;
% for i=2:2:numel(CondNames)
%     A = zeros(1,numel(CondNames));
%     A(i) = 1;
%     M{end}.Ac(:,3+Col(i),end+1) = A;
% end;
% M{end}.name       = 'A +V +T +Cdt spe ispi +Cdt spe contra';
% M{end}.numGparams = size(M{end}.Ac,3);
% M{end}.theta0=ones(size(M{end}.Ac,3),1);
% M{end}.fitAlgorithm = 'minimize';




% Free model as Noise ceiling
M{end+1}.type       = 'freechol';
M{end}.numCond    = numel(CondNames);
M{end}.name       = 'noiseceiling';
M{end}           = pcm_prepFreeModel(M{end});
M{end}.fitAlgorithm = 'minimize';

end