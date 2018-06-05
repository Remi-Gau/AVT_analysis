close all
clear
clc

figure


% Scaled
M_ori{1}.type       = 'feature';
M_ori{end}.Ac(:,:,1) = [1 0; 0 0 ]
M_ori{end}.Ac(:,:,2) = [0 0 ;1 0]
M_ori{end}.name       = 'Scaled';
M_ori{end}.numGparams = size(M_ori{end}.Ac,3);
M_ori{end}.fitAlgorithm = 'NR';



pp = 1
theta = -10:1:9;
theta2 = 5;
for n = 1:length(theta)
    
    
    % compute correlation
    var1 = theta2.^2; var2 = theta(n).^2; 
    cov12 = theta2*theta(n);
    my_corr(n) = cov12 / sqrt(var1*var2);
    
    % Plotting
    subplot(5,4,n)
    z1 = theta2*M_ori{pp}.Ac(:,:,1) +theta(n)*M_ori{pp}.Ac(:,:,2); 
    imagesc(z1*z1');
    colorbar
end


my_corr