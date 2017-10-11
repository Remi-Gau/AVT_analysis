clear 
clc

NbLayers = 6;

FileName = 'Sim_noise_midLayer_with_signal_5.gif';
% FileName = 'Sim_noise_midLayer.gif';

% Mu = zeros(1,NbLayers);
% Mu = -1*(1:NbLayers)/NbLayers;
Mu = [-0.6970   -0.6426   -0.8655   -1.1374   -1.4821   -1.8846];

% A=[1 1.5 2 2 1.5 1];
% Sigma_noise = A'*A;

Sigma_noise = [...
    2.6485    1.9059    1.0569    0.5610    0.3431    0.3011;...
    1.9059    2.6827    2.1034    1.1775    0.5344    0.3486;...
    1.0569    2.1034    2.8142    2.2895    1.1996    0.5430;...
    0.5610    1.1775    2.2895    2.9694    2.3133    1.1270;...
    0.3431    0.5344    1.1996    2.3133    2.9294    2.1847;...
    0.3011    0.3486    0.5430    1.1270    2.1847    3.0297];


%% Generate data
for iSess=1:20
    Dist(:,:,iSess) = mvnrnd(Mu, Sigma_noise, 6800);
end

for iLayer = 1:NbLayers % Averages over voxels of a given layer
    DistToPlot{iLayer} = mean(Dist(:,iLayer,:),3);
end


%% GLM
DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
DesMat = spm_orth(DesMat);

% Change or adapt dimensions for GLM
X=repmat(DesMat,size(Dist,3),1);

Y = shiftdim(Dist,1);
Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );

B = pinv(X)*Y;


%% Sort by the constant
[~,I] = sort(B(1,:));

Dist_sorted = Dist(I,:,:);


MeanProfiles = mean(Dist_sorted,3);


%% Plot
close all

% Color map
X = 0:0.001:1;

R = 0.237 - 2.13*X + 26.92*X.^2 - 65.5*X.^3 + 63.5*X.^4 - 22.36*X.^5;
G = ((0.572 + 1.524*X - 1.811*X.^2)./(1 - 0.291*X + 0.1574*X.^2)).^2;
B = 1./(1.579 - 4.03*X + 12.92*X.^2 - 31.4*X.^3 + 48.6*X.^4 - 23.36*X.^5);
ColorMap1 = [R' G' B'];

nMax = 20;

Splits = floor(linspace(1,size(Dist,1),nMax+1));

for n=1:nMax
    
    h = figure('name', ' ', 'Position', [100, 100, 1500, 1000]);
    
    subplot(3,2,1)
    colormap(ColorMap1)
    COV = cov(MeanProfiles);
    imagesc(COV, [-1*max(abs(COV(:))) max(abs(COV(:)))])
    axis('square')
    set(gca,'tickdir', 'out', 'xtick', 1:NbLayers , 'xticklabel',1:NbLayers, ...
        'ytick', 1:NbLayers , 'yticklabel',1:NbLayers, 'ticklength', [0.01 0.01], 'fontsize', 12)
    t=title('var-cov mat');
    set(t,'fontsize',12);
    t=xlabel('layer');
    set(t,'fontsize',12);
    t=ylabel('layer');
    set(t,'fontsize',12);
    colorbar
    
    
    subplot(3,2,2)
    distributionPlot(DistToPlot, 'xValues', 1:NbLayers, 'color', 'k', ...
        'distWidth', 0.8, 'showMM', 1, 'globalNorm', 2, 'histOpt', 1.1)
    set(gca,'tickdir', 'out', 'xtick', 1:NbLayers , ...
        'xticklabel',1:NbLayers, 'ytick', -100:2.5:100 , ...
        'yticklabel',-100:2.5:100, ...
        'ticklength', [0.01 0.01], 'fontsize', 12)
    axis([0 NbLayers+.5 -15 10])
    
    grid on
    
    t=title('Data dist');
    set(t,'fontsize',12);
    t=xlabel('layer');
    set(t,'fontsize',12);
    
    
    subplot(3,2,3:6)
    colormap(ColorMap1)
    imagesc(flipud(MeanProfiles))
    axis([0.5 6.5 0 size(Dist,1)])
    
    set(gca,'tickdir', 'out', 'xtick', 1:NbLayers,'xticklabel', 1:NbLayers, ...
        'ytick', [],'yticklabel', [], ...
        'ticklength', [0.01 0], 'fontsize', 10)
    
    
    tmp = axis;
    rec=rectangle('Position', [tmp(1) Splits(end-n) tmp(2)-tmp(1) Splits(end)-Splits(end-1)]);
    set(rec,'linewidth',2, 'EdgeColor', 'r')
    
    
    ax = gca;
    axes('Position',ax.Position);
    hold on
    
    plot(1:NbLayers,mean(MeanProfiles(Splits(n):Splits(n+1),:)),...
        'k', 'linewidth', 2)
    plot([1 6],[0 0], '--k')
    axis([0.5 6.5 -8 8])
 
    set(gca,'color', 'none', 'tickdir', 'out', 'xtick', 1:NbLayers,'xticklabel',  1:NbLayers, ...
        'YAxisLocation','right', 'ytick', -8:2:8,'yticklabel', -8:2:8, ...
        'ticklength', [0.01 0], 'fontsize', 10)
    
    
    pause(0.2)
    
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if n == 1
        imwrite(imind,cm,FileName,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,FileName,'gif','WriteMode','append');
    end
    
    close all
    
end