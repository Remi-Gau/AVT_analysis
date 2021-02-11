% (C) Copyright 2021 Uta Noppeney

% based on Makuergiaga et al., 2021

p2t_model = 6.5;
n_model= 10; % number of layers of Makuerkiaga
n = 6; % our number of layers

p2t = p2t_model * n/n_model + (n_model - n)/ (2*n_model);  % peak to tail adjusted for the number of layers

% BOLD-response with leakage (fake example mimicking V signals in A1 for contra)
y(1,:) = [-0.6 -0.3   0       0.4    0.5   0.7];  % Target
y(2,:) = [-0.3  -0.4  -0.5    -0.6   -0.8  -1];  % Stim

% Paralell leakage profiles
% y(1,:) = [-1 -2 -3 -4 -5 -6];
% y(2,:) = [-2 -3 -4 -5 -6 -7];

% % BOLD-response with leakage (fake example mimicking V and T signals in PT for contra)
% y(1,:) = [-0.2 -0.28   -0.32       -0.34    -0.4   -0.5];  % Visual
% y(2,:) = [ 0  -0.03  -0.1    -0.18   -0.22  -0.3];  % Tactile


for i = 1 : 2
    
    % All diag = 1
    peak = 1;
    tail = 1/p2t;

    X2 = tril(ones(n,n)*tail,-1) + diag(ones(n,1)*peak);
    beta(i,:) = pinv(X2)*y(i,:)';
    
    
    % Normalized way
    peak = y(i,1);
    tail = peak/p2t;

    X_normalized = tril(ones(n,n)*tail,-1) + diag(ones(n,1)*peak);
    beta_normalized(i,:) = pinv(X_normalized)*y(i,:)';

end


%plotting ...
figure; 

subplot(4,1,1); hold on
plot(1:6,beta(1,:),'r'); plot(1:6,beta(2,:),'b'); title('Non-normalized Leakage free individual conditions')

subplot(4,1,2); hold on
plot(1:6,beta(1,:)-beta(2,:),'g');title('Non-normalized Difference')

subplot(4,1,3); hold on
plot(1:6,beta_normalized(1,:),'r'); plot(1:6,beta_normalized(2,:),'b'); title('Normalized Leakage free individual conditions')

subplot(4,1,4); hold on
plot(1:6,beta_normalized(1,:)-beta_normalized(2,:),'g'); title('Normalized Leakage free difference')


figure
subplot(4,1,1); hold on
plot(1:6,y(1,:),'r'); plot(1:6,y(2,:),'b'); title('Original BOLD with leakage')

subplot(4,1,2); hold on
plot(1:6,y(1,:)-y(2,:),'g'); title('Original BOLD with leakage Difference')





