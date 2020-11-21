% (C) Copyright 2020 Remi Gau

function G_hat = ComputeGmatrix(Y, partVec, condVec)

    for iSub = 1:size(Y, 1)

        G_hat(:, :, iSub) = pcm_estGCrossval(Y{iSub}, partVec{iSub}, condVec{iSub}); %#ok<*AGROW>

    end

end
