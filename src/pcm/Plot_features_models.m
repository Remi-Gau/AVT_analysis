% (C) Copyright 2020 Remi Gau
clear;
clc;

% % Scaled
% M.type       = 'feature';
% M.Ac = [1 0]';
% M.Ac(:,1,2) = [0 1]';
% M.name       = 'Scaled';
% M.numGparams = size(M_ori{end}.Ac,3);
% M.fitAlgorithm = 'NR';

% % Scaled and independent
% M.type       = 'feature';
% M.Ac = [1 0]';
% M.Ac(:,1,2) = [0 1]';
% M.Ac(:,2,3) = [0 1]';
% M.name       = 'Scaled+Independent';
% M.numGparams = size(M.Ac,3);
% M.fitAlgorithm = 'NR';

% % Independent
% M.type       = 'feature';
% M.Ac = [1 0]';
% M.Ac(:,2,2) = [0 1]';
% M.name       = 'Independent';
% M.numGparams = size(M.Ac,3);
% M.fitAlgorithm = 'NR';

% A idpdt+scaled T-V,T idpdt-A,V idpdt
M.type = 'feature';
M.name = 'A idpdt+scaled T - V,T idpdt - A,V idpdt';
M.Ac = [];
M.Ac(:, 1, 1) = [1 0 0]';
M.Ac(:, 1, end + 1) = [0 0 1]';
M.Ac(:, 2, end + 1) = [1 0 0]';
M.Ac(:, 3, end + 1) = [0 1 0]';
M.numGparams = size(M.Ac, 3);
M.fitAlgorithm = 'NR';

%% compute each features component

%       G:        Second moment matrix
%       dGdtheta: Matrix derivatives in respect to parameters
%
%         case {'feature'}
%             A = bsxfun(@times,M.Ac,permute(theta,[3 2 1]));
%             A = sum(A,3);
%             G = A*A';
%             for i=1:M.numGparams
%                 dA = M.Ac(:,:,i)*A';
%                 dGdtheta(:,:,i) =  dA + dA';
%             end;

if isfield('theta0', M)
    [G, dGdtheta] = pcm_calculateG(M, M.theta0);
else
    [G, dGdtheta] = pcm_calculateG(M, ones(M.numGparams, 1));
end

%% plot

close all;
FigDim = [100, 50, 1300, 700];
figure('name', M.name, 'Position', FigDim);
ColorMap = brain_colour_maps('hot_increasing');
colormap(ColorMap);

SubPlot = 1;
nHorPan = 1;
nVerPan = M.numGparams;

c = pcm_indicatorMatrix('allpairs', 1:size(M.Ac, 1));

for iFeat = 1:M.numGparams

    g = M.Ac(:, :, iFeat) * M.Ac(:, :, iFeat)';
    RDM = diag(c * g * c');
    %     RDM = diag(c*dGdtheta(:,:,iFeat)*c');
    RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));

    subplot(nVerPan, nHorPan, SubPlot);
    imagesc(squareform(RDM));
    axis square;
    set(gca, 'Xtick', 1:size(M.Ac(:, :, iFeat), 2), 'Ytick', 1:size(M.Ac(:, :, iFeat), 1), ...
        'Xticklabel', [], 'Yticklabel', [], 'tickdir', 'out', 'fontsize', 6);

    SubPlot = SubPlot + 1;

end

mtit(M.name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);
