% compute RSA distances (A --> B) in a cross validated fashion
A =  rsa.distanceLDC(Y{iSub}(:, Vert2Take), partVec{iSub}, condVec{iSub});

% because when doing cross validation distance A --> B can be different
% from B-->A we recompute the RSA in the other direction and take the
% mean of both directions

% compute RSA distances (B --> A) in a cross validated fashion
% flipup the data and the partition vector means that condition label
% used to be 1:6 is now 6:-1:1
B =  rsa.distanceLDC(flipud(Y{iSub}(:, Vert2Take)), flipud(partVec{iSub}), condVec{iSub});
% flip the distance back
B = fliplr(B);
B = [B(1:2) B(4) B(7) B(11) B(3) B(5) B(8) B(12) B(6) B(9) B(13) B(10) B(14:15)];
% take the mean
RDMs_CV(:, :, iSub, iSplit) = squareform(mean([A; B]));

%% Compute CVed G-matrix, do multidimensional scaling
G_hat(:, :, iSub, iSplit) = pcm_estGCrossval(Y{iSub}(:, Vert2Take), partVec{iSub}, condVec{iSub});

%%
% Eucledian normalization
for i = 1:size(X, 1)
    X(i, :) = X(i, :) / norm(X(i, :));
end
clear i;

A =  rsa.distanceLDC(X, partitionVec, conditionVec);
B =  rsa.distanceLDC(flipud(X), flipud(partitionVec), conditionVec);
B = fliplr(B);
RDMs{iROI, iHS, iTarget + 1} = squareform(mean([A; B]));
