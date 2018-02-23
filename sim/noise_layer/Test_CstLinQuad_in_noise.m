clear; clc; close all

Start_dir = fullfile(filesep,'home','rxg243','Dropbox','PhD','Experiments','AVT','derivatives');

NbLayers = 6;
NbVertices = 5000;
NbSubj = 10;
NbSess = 20;

NbSim = 10^5;
PrintOutEvery = 10^3;

Mu = zeros(1,NbLayers);

Sigma_noise = [...
    2.6485    1.9059    1.0569    0.5610    0.3431    0.3011;...
    1.9059    2.6827    2.1034    1.1775    0.5344    0.3486;...
    1.0569    2.1034    2.8142    2.2895    1.1996    0.5430;...
    0.5610    1.1775    2.2895    2.9694    2.3133    1.1270;...
    0.3431    0.5344    1.1996    2.3133    2.9294    2.1847;...
    0.3011    0.3486    0.5430    1.1270    2.1847    3.0297];

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
DesMat = spm_orth(DesMat);
X=repmat(DesMat,NbSess,1);

for iSub=1:NbSubj
    sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];


%%
t = tic;
T = [];
for iSim = 1:NbSim
    
    if mod(iSim,PrintOutEvery)==0
        
        T(end+1)=toc(t);
        
        sec = round((NbSim-iSim)*mean(T/PrintOutEvery));
        hrs = floor(sec/3600);
        min = floor(mod(sec,3600)/60);
        
        fprintf('Simulation %i\n', iSim)
        fprintf(1,'Avg time elapsed / simulation = %0.3f secs ; ETA = %i hrs %i min\n',...
            mean(T/PrintOutEvery), hrs, min);
        
        t = tic;
    end
    
    for iSubj = 1:NbSubj
        
        %     SubjNoise =  randn(NbLayers)/10;
        for iSess=1:NbSess
            % Generate data
            Dist(:,:,iSess) = mvnrnd(Mu, Sigma_noise, NbVertices); %#ok<*SAGROW>
        end
        
        % Change or adapt dimensions for GLM
        Y = shiftdim(Dist,1);
        Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
        
        % GLM for each vertex and take the mean of that
        betas(iSubj,1:size(DesMat,2)) = mean(pinv(X)*Y,2);
        
    end
    
    [h,p]=ttest(betas, 0, 'tail', 'both');
    Results_ttest(iSim,:) = p;
    
    % do permutation tests
    for ibeta = 1:size(betas,2)
        tmp = repmat(betas(:,ibeta)',size(ToPermute,1),1);
        Perms = mean(ToPermute.*tmp,2);
        p(ibeta) = sum( abs((Perms-mean(Perms))) > abs((mean(betas(:,ibeta))-mean(Perms))) ) / numel(Perms) ;
        p2(ibeta) = sum( abs(Perms) > abs(mean(betas(:,ibeta))) ) / numel(Perms) ;
        Nulls(:,ibeta,iSim)=Perms;
    end
    
    Results_perm(iSim,:) = p;
    Results_perm2(iSim,:) = p2;
    
end

save(fullfile(Start_dir,'results','sim','p-curve_profiles',...
    ['simulation_profiles_cst_lin_quad_' datestr(now, 'yyyy_mm_dd_HH_MM') '.mat']),'-v7.3',...
    'Results_perm','Results_ttest','Results_perm2','Nulls')

%% plot
NbBins = 100;

close all

figure('name', 'Simulation Cst Lin Quad', 'Position', [100, 100, 1000, 700], 'Color', [1 1 1]);


subplot(321)
hist(Results_ttest(:,1),NbBins);
H(1,1:NbBins) = hist(Results_ttest(:,1),NbBins);
ylabel('Constant')
title('T-test')

subplot(323)
hist(Results_ttest(:,2),NbBins);
H(2,1:NbBins) = hist(Results_ttest(:,2),NbBins);
ylabel('Linear')

subplot(325)
hist(Results_ttest(:,3),NbBins);
H(3,1:NbBins) = hist(Results_ttest(:,3),NbBins);
ylabel('Quadratic')



% subplot(332)
% hist(Results_perm(:,1),NbBins);
% H(4,1:NbBins) = hist(Results_perm(:,1),NbBins);
% title('Permutation test')
% 
% subplot(335)
% hist(Results_perm(:,2),NbBins);
% H(5,1:NbBins) = hist(Results_perm(:,2),NbBins);
% 
% subplot(338)
% hist(Results_perm(:,1),NbBins);
% H(6,1:NbBins) = hist(Results_perm(:,3),NbBins);



subplot(322)
hist(Results_perm2(:,1),NbBins);
H(4,1:NbBins) = hist(Results_perm2(:,1),NbBins);
title('Permutation test')

subplot(324)
hist(Results_perm2(:,2),NbBins);
H(5,1:NbBins) = hist(Results_perm2(:,2),NbBins);

subplot(326)
hist(Results_perm2(:,1),NbBins);
H(6,1:NbBins) = hist(Results_perm2(:,3),NbBins);


for i=1:6
    subplot(3,2,i)
    hold on
    
    plot([.05 .05], [0 max(H(:))], 'r', 'linewidth', 2)
    
    [x,y] = ind2sub([3,2],i);
    switch y
        case 1
            tmp=Results_ttest;
        case 2
            tmp=Results_perm2;
%         case 3
%             tmp=Results_perm2;
            
    end
    text(.7, max(H(:)), sprintf('p(p<.05)=%.04f',mean(tmp(:,x)<.05)))
    
    set(gca, 'xtick', 0:.1:1,'xticklabel', 0:.1:1)
    xlabel('p-value')
    axis([0 1 0 max(H(:))*1.1])
end


%%

for i=1:size(Nulls,3)
    H(i,:)=hist(Nulls(:,2,i),100);
end

tmp = mean(H,1);

%%

hist(Nulls(:,2,596),100)