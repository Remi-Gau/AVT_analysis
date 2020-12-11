function M = Set_PCM_models_feature(AuditoryOrVisual)
    
    if nargin < 1 || isempty(AuditoryOrVisual)
        AuditoryOrVisual = 'auditory';
    end

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
M{1}.name       = 'null';
M{1}.fitAlgorithm = 'minimize';



% 1rst column: Ipsi-contra
%   1 --> scaled
%   2 --> independent and scaled.
%   3 --> independent
% 2nd column: condition
%   1 --> all scaled
%   2 --> preferred and non-preferred are scaled and independe;non-prefered as scaled versions of each other
%   3 --> preferred and non prefered are independent, non prefered are
%   scaled versions of each other
%   4 --> preferred and non prefered are independent, non prefered are
%   scaled versions of each other but also indepedent
%   5 --> all independent
% 3rd column: one feature for ipsi of all condition + one feature for contra of all condition
%   1 --> no
%   2 --> yes

sets = {1:3,1:5,1:2};
[x, y, z] = ndgrid(sets{:});
Features_to_add = [x(:) y(:) z(:)];


for iModel_2_create = 1:size(Features_to_add,1)  % Ipsi vs. contra
    M{end+1}.type       = 'feature';
    M{end}.Ac = [0 0 0 0 0 0]';
    
    IpsiContraScaled = Features_to_add(iModel_2_create,1);   
    
    switch Features_to_add(iModel_2_create,2)  % Modality
        case 1
            M = All_scaled(M,CondNames,IpsiContraScaled);
        case 2
            M = All_scaled(M,CondNames,IpsiContraScaled);
            if strcmpi(AuditoryOrVisual, 'auditory')
                M = NonPref_scaled_A(M,CondNames,IpsiContraScaled);
            else strcmpi(AuditoryOrVisual, 'visual')
                M = NonPref_scaled_V(M,CondNames,IpsiContraScaled);
            end
        case 3  
            M = Pref_idpdt(M,CondNames,IpsiContraScaled,AuditoryOrVisual);
            if AuditoryOrVisual==1
                M = NonPref_scaled_A(M,CondNames,IpsiContraScaled);
            else
                M = NonPref_scaled_V(M,CondNames,IpsiContraScaled);
            end
        case 4
            M = Pref_idpdt(M,CondNames,IpsiContraScaled,AuditoryOrVisual);
            if AuditoryOrVisual==1
                M = NonPref_scaled_A(M,CondNames,IpsiContraScaled);
            else
                M = NonPref_scaled_V(M,CondNames,IpsiContraScaled);
            end
            M = NonPref_idpdt(M,CondNames,IpsiContraScaled);
        case 5
            M = All_idpdt(M,CondNames,IpsiContraScaled);
    end
    
    
    switch Features_to_add(iModel_2_create,3)
        case 1
        case 2
           M = General_ipsi_contra(M);
    end
    
    M{end}.Ac(:,:,1) = [];
    M{end}.Ac(:,all(all(M{end}.Ac==0),3),:) = [];
    
    M{end}.numGparams = size(M{end}.Ac,3);
    % M{end}.theta0=ones(size(M{end}.Ac,3),1);
    M{end}.fitAlgorithm = Alg;
    
    M{end}.name = [...
        num2str(Features_to_add(iModel_2_create,1)) ',' ...
        num2str(Features_to_add(iModel_2_create,2)) ',' ...
        num2str(Features_to_add(iModel_2_create,3))];
    
end


% Free model as Noise ceiling
M{end+1}.type       = 'freechol';
M{end}.numCond    = numel(CondNames);
M{end}.name       = 'noiseceiling';
M{end}           = pcm_prepFreeModel(M{end});
M{end}.fitAlgorithm = 'minimize';

end


function M = All_scaled(M,CondNames,IpsiContraScaled)
if IpsiContraScaled==1
  col_num = [1 1 1 1 1 1];  
else
  col_num = [1 2 1 2 1 2];
end
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,col_num(i),end+1) = A;
    if IpsiContraScaled==2 && mod(col_num(i),2)==0
        A = zeros(1,numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:,col_num(i)-1,end+1) = A;
    end
end
end


function M = Pref_idpdt(M,CondNames,IpsiContraScaled,A_or_V)
if A_or_V 
    Cdt = 1:2;
else
    Cdt = 3:4;
end
if IpsiContraScaled==1
    if A_or_V
        col_num = [1 1];  
    else
        col_num = [3 3];
    end
else
    if A_or_V
        col_num = [1 2];
    else
        col_num = [3 4];
    end
end
for i=Cdt
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,col_num(i),end+1) = A;
    if IpsiContraScaled==2 && mod(col_num(i),2)==0
        A = zeros(1,numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:,col_num(i)-1,end+1) = A;
    end
end
end


function M = NonPref_scaled_A(M,CondNames,IpsiContraScaled)
if IpsiContraScaled==1
  col_num = [0 0 3 3 3 3];  
else
  col_num = [0 0 3 4 3 4];
end
for i=3:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,col_num(i),end+1) = A;
    if IpsiContraScaled==2 && mod(col_num(i),2)==0
        A = zeros(1,numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:,col_num(i)-1,end+1) = A;
    end
end
end


function M = NonPref_scaled_V(M,CondNames,IpsiContraScaled)
if IpsiContraScaled==1
  col_num = [3 3 0 0 3 3];  
else
  col_num = [3 4 0 0 3 4];
end
for i=[1 2 5 6]
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,col_num(i),end+1) = A;
    if IpsiContraScaled==2 && mod(col_num(i),2)==0
        A = zeros(1,numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:,col_num(i)-1,end+1) = A;
    end
end
end


function M = NonPref_idpdt(M,CondNames,IpsiContraScaled)
if IpsiContraScaled==1
  col_num = [0 0 0 0 5 5];  
else
  col_num = [0 0 0 0 5 6];
end
for i=[5 6]
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,col_num(i),end+1) = A;
    if IpsiContraScaled==2 && mod(col_num(i),2)==0
        A = zeros(1,numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:,col_num(i)-1,end+1) = A;
    end
end
end


function M = All_idpdt(M,CondNames,IpsiContraScaled)
if IpsiContraScaled==1
    col_num = [1 1 2 2 3 3];  
else
    col_num = 1:6;
end
for i=1:numel(CondNames)
    A = zeros(1,numel(CondNames));
    A(i) = 1;
    M{end}.Ac(:,col_num(i),end+1) = A;
    if IpsiContraScaled==2 && mod(i,2)==0
        A = zeros(1,numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:,col_num(i)-1,end+1) = A;
    end
end
end

function M = General_ipsi_contra(M)
M{end}.Ac(:,end+1,end+1) = [1 0 1 0 1 0];
M{end}.Ac(:,end+1,end+1) = [0 1 0 1 0 1];
end



