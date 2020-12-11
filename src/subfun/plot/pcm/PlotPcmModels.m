% (C) Copyright 2020 Remi Gau

function fig_handles = PlotPcmModels(M)
    %
    % works for feature based model at the moment

    % TODO
    % add name of conditions

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

    ColorMap = BrainColourMaps('hot_increasing');

    Opt.Visible = 'on';

    FigDim = [100, 50, 1300, 700];

    for iM = 1:numel(M)

        if strcmp(M{iM}.type, 'feature')

            fig_handles(iM) = figure('name', M{iM}.name, 'Position', FigDim); %#ok<*AGROW>

            SetFigureDefaults(Opt);

            PlotType1(M{iM});
            % PlotType2(M{iM});

            colormap(ColorMap);

            mtit(M{iM}.name, ...
                 'fontsize', 12, ...
                 'xoff', 0, ...
                 'yoff', .035);

        end

    end

end

function PlotType1(Model)

    FONTSIZE = 8;

    SubPlot = 1;

    nVerPan = Model.numGparams + 1;
    nHorPan = 3;

    %% plot sum features
    subplot(nVerPan, nHorPan, SubPlot);

    imagesc(sum(Model.Ac, 3));
    t = title('feature');
    set(t, 'fontsize', FONTSIZE);

    SubPlot = SetAxis(SubPlot);
    t = ylabel('sum(features)');
    set(t, 'fontsize', FONTSIZE);

    %% plot G matrix
    [G, dGdtheta] = pcm_calculateG(Model, ones(Model.numGparams, 1));
    if isfield('theta0', Model)
        [G, dGdtheta] = pcm_calculateG(Model, Model.theta0);
    end

    subplot(nVerPan, nHorPan, SubPlot);

    imagesc(G);

    SubPlot = SetAxis(SubPlot);
    axis square;
    t = title('dG dtheta');
    set(t, 'fontsize', FONTSIZE);

    %% RDM
    c = pcm_indicatorMatrix('allpairs', 1:size(Model.Ac, 1));

    subplot(nVerPan, nHorPan, SubPlot);

    RDM = diag(c * G * c');
    RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));
    imagesc(squareform(RDM));

    SubPlot = SetAxis(SubPlot);
    axis square;
    t = title('RDM');
    set(t, 'fontsize', FONTSIZE);

    %%
    for iFeat = 1:nVerPan - 1

        %%
        subplot(nVerPan, nHorPan, SubPlot);

        imagesc(Model.Ac(:, :, iFeat));

        SubPlot = SetAxis(SubPlot);

        set(gca, ...
            'Xtick', 1:size(Model.Ac(:, :, iFeat), 2), ...
            'Ytick', 1:size(Model.Ac(:, :, iFeat), 1), ...
            'Xticklabel', [], ...
            'Yticklabel', [], ...
            'tickdir', 'out');
        t = ylabel(num2str(iFeat));
        set(t, 'fontsize', FONTSIZE);

        %%
        subplot(nVerPan, nHorPan, SubPlot);

        imagesc(dGdtheta(:, :, iFeat));

        SubPlot = SetAxis(SubPlot);
        axis square;

        %%
        subplot(nVerPan, nHorPan, SubPlot);

        RDM = diag(c * dGdtheta(:, :, iFeat) * c');
        RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));
        imagesc(squareform(RDM));

        SubPlot = SetAxis(SubPlot);
        axis square;

    end

end

function PlotType2(Model)

    FONTSIZE = 8;

    A = 0;

    theta = ones(1, Model.numGparams);

    % loops that adds each feature progressively
    SubPlot = 1;

    for i = 1:Model.numGparams

        A = A + theta(i) * Model.Ac(:, :, i);

        subplot(Model.numGparams, 4, SubPlot);
        imagesc(Model.Ac(:, :, i));
        SubPlot = SetAxis(SubPlot);
        t = ylabel(sprintf('feature number: %i', i));
        set(t, 'fontsize', FONTSIZE);

        subplot(Model.numGparams, 4, SubPlot);
        imagesc(A);
        SubPlot = SetAxis(SubPlot);
        t = ylabel(sprintf('sum features 1:%i', i));
        set(t, 'fontsize', FONTSIZE);

        subplot(Model.numGparams, 4, SubPlot);
        imagesc(A');
        SubPlot = SetAxis(SubPlot);

        subplot(Model.numGparams, 4, SubPlot);
        imagesc(A * A');
        SubPlot = SetAxis(SubPlot);
        axis square;

    end

    subplot(Model.numGparams, 4, 1);
    t = title('Features');
    set(t, 'fontsize', FONTSIZE);

    subplot(Model.numGparams, 4, 2);
    t = title("A");
    set(t, 'fontsize', FONTSIZE);

    subplot(Model.numGparams, 4, 3);
    t = title("A'");
    set(t, 'fontsize', FONTSIZE);

    subplot(Model.numGparams, 4, 4);
    t = title("A * A'");
    set(t, 'fontsize', FONTSIZE);

end

function SubPlot = SetAxis(SubPlot)

    set(gca, ...
        'Xtick', [], ...
        'Ytick', []);

    SubPlot = SubPlot + 1;

end
