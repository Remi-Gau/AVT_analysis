% Models for Remi
% 
% 
% 
% Let�s go through example of visual areas
% V = preferred
% A, T = nonpreferred
% 
% Ipsi vs. contra
% 
% Now there are three options
% 1. only scaled versions  = s; ie. S: a,v means A and V are scaled version
% 2. completely independent = i
% 3. scaled + independent = i+s
% 
% Now we do it factorially
% Factor 1: Do stimuli from different sensory modalities elicit common, independent or partly shared representations
% Factor 2: Do stimuli from ipsi vs. contra elicit common, independent or partly shared representations
% Factor 3: Do we have additional ipsi vs, contra expression
% 
% 	S: A,V,T	S+I:V vs. A,T
% S: A, T	S+I:A,V,T	I: V vs. (A,T)
% S: A,T	I: V vs. (A,T)
% S+I: A,T	I:A,V,T
% S: Ipsi, Contra						
% I+S: Ipsi, Contra						
% I: Ipsi vs. Contra						
% 
% 
% 
% So we test 30 models!   � but importantly, plotting the model evidence factorially (e.g. using imagesc) provides a more clear picture of what really influence those pattern
% 





runEffect  = 'fixed';
alg = 'minimize'; 

% --------------------------------------
% ALTERNATIVE specification - INDEED LOOKS identical to next one in the end
% Model 2,1,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% mm = 1; 
% M{mm}.type       = 'feature';
% M{mm}.numGparams = 11;
% 
% % Ipsi A, V, T scales versions of one another
% M{mm}.Ac = zeros(6,6,M{mm}.numGparams);
% M{mm}.Ac(1,1 ,1)    = 1;    % A
% M{mm}.Ac(3,1 ,2)    = 1;    % V
% M{mm}.Ac(5,1 ,3)    = 1;    % T
% 
% 
% % Contra A, V, T scales versions of one another
% i = 1;
% M{mm}.Ac(1+i,1+i ,4)    = 1;    % A
% M{mm}.Ac(3+i,1+i ,5)    = 1;    % V
% M{mm}.Ac(5+i,1+i ,6)    = 1;    % T
% 
% 
% % Contra and Ipsi - Shared; A, V, T scales versions of one another
% i = 1;
% M{mm}.Ac(1+i,1 ,7)    = 1;    % A
% M{mm}.Ac(3+i,1 ,8)    = 1;    % V
% M{mm}.Ac(5+i,1 ,9)    = 1;    % T
% 
% 
% % Non-specific effects of ipsi and contra
% M{mm}.Ac(:,7,10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
% M{mm}.Ac(:,8,11) = [0 1 0 1 0 1]';       
% 
% M{mm}.theta0=ones(M{mm}.numGparams,1);                        
% M{mm}.fitAlgorithm = alg; 


%--------------------------------------------------------------------------
% Model 2,1,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
mm = 1; 
M{mm}.type       = 'feature';
M{mm}.numGparams = 11;

M{mm}.Ac = zeros(6,6,M{mm}.numGparams);

% Preferred
M{mm}.Ac(1,1 ,1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2,2 ,2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2,1 ,3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2 ; j = 0;
M{mm}.Ac(i+1,j+1 ,4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4 ; j = 0;
M{mm}.Ac(i+1,j+1 ,7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,9)    = 1;    % Preferred modality, contra, scaled of ipsi


% Non-specific effects of ipsi and contra
M{mm}.Ac(:,7,10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:,8,11) = [0 1 0 1 0 1]';       

M{mm}.theta0=ones(M{mm}.numGparams,1);                        
M{mm}.fitAlgorithm = alg; 


%--------------------------------------------------------------------------
% Model 2,2,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has shared and independent representations for Preferred and
% Nonprefered; but the two preferred have shared representations

mm = 2; 
M{mm}.type       = 'feature';
M{mm}.numGparams = 17;

M{mm}.Ac = zeros(6,6,M{mm}.numGparams);

% Preferred
M{mm}.Ac(1,1 ,1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2,2 ,2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2,1 ,3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2 ; j = 0;
M{mm}.Ac(i+1,j+1 ,4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4 ; j = 0;
M{mm}.Ac(i+1,j+1 ,7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,9)    = 1;    % Preferred modality, contra, scaled of ipsi


% Non preferred 1 Modality
i = 2 ; j = 2;
M{mm}.Ac(i+1,j+1 ,10)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,11)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,12)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4 ; j = 2;
M{mm}.Ac(i+1,j+1 ,13)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,14)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,15)    = 1;    % Preferred modality, contra, scaled of ipsi



% Non-specific effects of ipsi and contra
M{mm}.Ac(:,7,16) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:,8,17) = [0 1 0 1 0 1]';       

M{mm}.theta0=ones(M{mm}.numGparams,1);                        
M{mm}.fitAlgorithm = alg; 


%--------------------------------------------------------------------------
% Model 2,3,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has only independent representations for Preferred and
% Nonprefered; but the two preferred have shared only representations

mm = 3; 
M{mm}.type       = 'feature';
M{mm}.numGparams = 11;

M{mm}.Ac = zeros(6,6,M{mm}.numGparams);

% Preferred
M{mm}.Ac(1,1 ,1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2,2 ,2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2,1 ,3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2 ; j = 2;
M{mm}.Ac(i+1,j+1 ,4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4 ; j = 2;
M{mm}.Ac(i+1,j+1 ,7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,9)    = 1;    % Preferred modality, contra, scaled of ipsi



% Non-specific effects of ipsi and contra
M{mm}.Ac(:,7,10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:,8,11) = [0 1 0 1 0 1]';       

M{mm}.theta0=ones(M{mm}.numGparams,1);                        
M{mm}.fitAlgorithm = alg; 


%--------------------------------------------------------------------------
% Model 2,4,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has only independent representations for Preferred and
% Nonprefered; but the two preferred have shared and independent representations

mm = 4; 
M{mm}.type       = 'feature';
M{mm}.numGparams = 14;

M{mm}.Ac = zeros(6,6,M{mm}.numGparams);

% Preferred
M{mm}.Ac(1,1 ,1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2,2 ,2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2,1 ,3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2 ; j = 2;
M{mm}.Ac(i+1,j+1 ,4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,6)    = 1;    % Preferred modality, contra, scaled of ipsi


% Non preferred 2 Modality (indpendent)
i = 4 ; j = 4;
M{mm}.Ac(i+1,j+1 ,7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,9)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality (shared)
i = 4 ; j = 2;
M{mm}.Ac(i+1,j+1 ,10)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,11)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,12)    = 1;    % Preferred modality, contra, scaled of ipsi


% Non-specific effects of ipsi and contra
M{mm}.Ac(:,7,13) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:,8,14) = [0 1 0 1 0 1]';       

M{mm}.theta0=ones(M{mm}.numGparams,1);                        
M{mm}.fitAlgorithm = alg; 

%--------------------------------------------------------------------------
% Model 2,5,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has only independent representations for all three
% modalities

mm = 5; 
M{mm}.type       = 'feature';
M{mm}.numGparams = 11;

M{mm}.Ac = zeros(6,6,M{mm}.numGparams);

% Preferred
M{mm}.Ac(1,1 ,1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2,2 ,2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2,1 ,3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2 ; j = 2;
M{mm}.Ac(i+1,j+1 ,4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,6)    = 1;    % Preferred modality, contra, scaled of ipsi


% Non preferred 2 Modality (indpendent)
i = 4 ; j = 4;
M{mm}.Ac(i+1,j+1 ,7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i+2,j+2 ,8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i+2,j+1 ,9)    = 1;    % Preferred modality, contra, scaled of ipsi



% Non-specific effects of ipsi and contra
M{mm}.Ac(:,7,10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:,8,11) = [0 1 0 1 0 1]';       

M{mm}.theta0=ones(M{mm}.numGparams,1);                        
M{mm}.fitAlgorithm = alg; 


% figure

figure
A = 0; k = 10;
zz = 2;
theta = 1 : 1: M{zz}.numGparams;
theta = ones(1,M{zz}.numGparams);
for i = 1 : M{zz}.numGparams
    
    A = A + theta(i)* M{zz}.Ac(:,:,i);
    
    subplot(M{zz}.numGparams,4,4*(i-1)+1);
    imagesc(M{zz}.Ac(:,:,i))
    subplot(M{zz}.numGparams,4,4*(i-1)+2);
    imagesc(A)
    subplot(M{zz}.numGparams,4,4*(i-1)+3);
    imagesc(A')
    subplot(M{zz}.numGparams,4,4*(i-1)+4)
    imagesc(A*A')
    
end




% % figure
% 
% figure
% A = 0; k = 10;
% zz =1;
% theta = 1 : 1: M{zz}.numGparams;
% theta = ones(1,M{zz}.numGparams);
% for i = 1 : M{zz}.numGparams
%     A = A + theta(i)* M{zz}.Ac(:,:,i);
%     
%     subplot(3,M{zz}.numGparams,i);
%     imagesc(A)
%     subplot(3,M{zz}.numGparams,M{zz}.numGparams+i);
%     imagesc(A')
%     subplot(3,M{zz}.numGparams,(M{zz}.numGparams)*2+i)
%     imagesc(A*A')
%     
% end

