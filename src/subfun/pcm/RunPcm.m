% (C) Copyright 2020 Remi Gau

function varargout = RunPcm(Y, M, partVec, condVec)
    %
    % Runs PCM and cross validated PCM at the group level
    %
    % USAGE::
    %
    %  [T_grp, theta_grp, G_pred_grp, T_cr, theta_cr, G_pred_cr] = RunPcm(Y, M, partVec, condVec)
    %

    MaxIteration = 50000;
    runEffect  = 'fixed';

    % Fit the models on the group level
    fprintf('\n\n  Running PCM\n\n');

    [T_grp, theta_grp, G_pred_grp] = pcm_fitModelGroup(Y, M, partVec, condVec, ...
                                                       'runEffect', runEffect, ...
                                                       'fitScale', 1);

    [T_cr, theta_cr, G_pred_cr] = pcm_fitModelGroupCrossval(Y, M, partVec, condVec, ...
                                                            'runEffect', runEffect, ...
                                                            'groupFit', theta_grp, ...
                                                            'fitScale', 1, ...
                                                            'MaxIteration', MaxIteration);

    varargout = { ...
                 T_grp; ...
                 theta_grp; ...
                 G_pred_grp; ...
                 T_cr; ...
                 theta_cr; ...
                 G_pred_cr};

end
