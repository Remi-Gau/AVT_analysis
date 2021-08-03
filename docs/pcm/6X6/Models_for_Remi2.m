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

% --------------------------------------------------------------------------
% Model 2,1,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
mm = 1;
M{mm}.type       = 'feature';
M{mm}.numGparams = 11;

M{mm}.Ac = zeros(6, 6, M{mm}.numGparams);

% Preferred
M{mm}.Ac(1, 1, 1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2, 2, 2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2, 1, 3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2;
j = 0;
M{mm}.Ac(i + 1, j + 1, 4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4;
j = 0;
M{mm}.Ac(i + 1, j + 1, 7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 9)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non-specific effects of ipsi and contra
M{mm}.Ac(:, 7, 10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:, 8, 11) = [0 1 0 1 0 1]';

M{mm}.theta0 = ones(M{mm}.numGparams, 1);
M{mm}.fitAlgorithm = alg;

% --------------------------------------------------------------------------
% Model 2,2,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has shared and independent representations for Preferred and
% Nonprefered; but the two preferred have shared representations

mm = 2;
M{mm}.type       = 'feature';
M{mm}.numGparams = 17;

M{mm}.Ac = zeros(6, 6, M{mm}.numGparams);

% Preferred
M{mm}.Ac(1, 1, 1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2, 2, 2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2, 1, 3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2;
j = 0;
M{mm}.Ac(i + 1, j + 1, 4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4;
j = 0;
M{mm}.Ac(i + 1, j + 1, 7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 9)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2;
j = 2;
M{mm}.Ac(i + 1, j + 1, 10)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 11)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 12)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4;
j = 2;
M{mm}.Ac(i + 1, j + 1, 13)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 14)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 15)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non-specific effects of ipsi and contra
M{mm}.Ac(:, 7, 16) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:, 8, 17) = [0 1 0 1 0 1]';

M{mm}.theta0 = ones(M{mm}.numGparams, 1);
M{mm}.fitAlgorithm = alg;

% --------------------------------------------------------------------------
% Model 2,3,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has only independent representations for Preferred and
% Nonprefered; but the two preferred have shared only representations

mm = 3;
M{mm}.type       = 'feature';
M{mm}.numGparams = 11;

M{mm}.Ac = zeros(6, 6, M{mm}.numGparams);

% Preferred
M{mm}.Ac(1, 1, 1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2, 2, 2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2, 1, 3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2;
j = 2;
M{mm}.Ac(i + 1, j + 1, 4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality
i = 4;
j = 2;
M{mm}.Ac(i + 1, j + 1, 7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 9)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non-specific effects of ipsi and contra
M{mm}.Ac(:, 7, 10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:, 8, 11) = [0 1 0 1 0 1]';

M{mm}.theta0 = ones(M{mm}.numGparams, 1);
M{mm}.fitAlgorithm = alg;

% --------------------------------------------------------------------------
% Model 2,4,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has only independent representations for Preferred and
% Nonprefered; but the two preferred have shared and independent representations

mm = 4;
M{mm}.type       = 'feature';
M{mm}.numGparams = 14;

M{mm}.Ac = zeros(6, 6, M{mm}.numGparams);

% Preferred
M{mm}.Ac(1, 1, 1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2, 2, 2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2, 1, 3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2;
j = 2;
M{mm}.Ac(i + 1, j + 1, 4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality (indpendent)
i = 4;
j = 4;
M{mm}.Ac(i + 1, j + 1, 7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 9)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality (shared)
i = 4;
j = 2;
M{mm}.Ac(i + 1, j + 1, 10)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 11)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 12)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non-specific effects of ipsi and contra
M{mm}.Ac(:, 7, 13) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:, 8, 14) = [0 1 0 1 0 1]';

M{mm}.theta0 = ones(M{mm}.numGparams, 1);
M{mm}.fitAlgorithm = alg;

% --------------------------------------------------------------------------
% Model 2,5,2  (these numbers refer to the table of models, each number
% indicates the level of this model factor
% This model now has only independent representations for all three
% modalities

mm = 5;
M{mm}.type       = 'feature';
M{mm}.numGparams = 11;

M{mm}.Ac = zeros(6, 6, M{mm}.numGparams);

% Preferred
M{mm}.Ac(1, 1, 1)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(2, 2, 2)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(2, 1, 3)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 1 Modality
i = 2;
j = 2;
M{mm}.Ac(i + 1, j + 1, 4)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 5)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 6)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non preferred 2 Modality (indpendent)
i = 4;
j = 4;
M{mm}.Ac(i + 1, j + 1, 7)    = 1;    % Preferred modality, ipsi
M{mm}.Ac(i + 2, j + 2, 8)    = 1;    % Preferred modality, contra, independent
M{mm}.Ac(i + 2, j + 1, 9)    = 1;    % Preferred modality, contra, scaled of ipsi

% Non-specific effects of ipsi and contra
M{mm}.Ac(:, 7, 10) = [1 0 1 0 1 0]';       % i,e, non-specific ipsi vs, contra expression models top-down attentional effects
M{mm}.Ac(:, 8, 11) = [0 1 0 1 0 1]';

M{mm}.theta0 = ones(M{mm}.numGparams, 1);
M{mm}.fitAlgorithm = alg;
