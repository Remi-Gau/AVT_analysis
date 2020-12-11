% (C) Copyright 2020 Remi Gau

function fig_handles = PlotPcmModels(M)
    %
    % works for feature based model at the moment

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
    FONTSIZE = 8;

    for iM = 1:numel(M)

        if strcmp(M{iM}.type, 'feature')

            fig_handles(iM) = figure('name', M{iM}.name, 'Position', FigDim);

            SetFigureDefaults(Opt);

            SubPlot = 1;

            nVerPan = M{iM}.numGparams + 1;
            nHorPan = 3;

            %% plot sum features
            subplot(nVerPan, nHorPan, SubPlot);

            imagesc(sum(M{iM}.Ac, 3));
            t = title('feature');
            set(t, 'fontsize', FONTSIZE);

            SubPlot = SetAxis(SubPlot, ColorMap);
            t = ylabel('sum(features)');
            set(t, 'fontsize', FONTSIZE);

            %% plot G matrix
            [G, dGdtheta] = pcm_calculateG(M{iM}, ones(M{iM}.numGparams, 1));
            if isfield('theta0', M{iM})
                [G, dGdtheta] = pcm_calculateG(M{iM}, M{iM}.theta0);
            end

            subplot(nVerPan, nHorPan, SubPlot);

            imagesc(G);

            SubPlot = SetAxis(SubPlot, ColorMap);
            axis square;
            t = title('dG dtheta');
            set(t, 'fontsize', FONTSIZE);

            %% RDM
            c = pcm_indicatorMatrix('allpairs', 1:size(M{iM}.Ac, 1));

            subplot(nVerPan, nHorPan, SubPlot);

            RDM = diag(c * G * c');
            RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));
            imagesc(squareform(RDM));

            SubPlot = SetAxis(SubPlot, ColorMap);
            axis square;
            t = title('RDM');
            set(t, 'fontsize', FONTSIZE);

            %%
            for iFeat = 1:nVerPan - 1

                %%
                subplot(nVerPan, nHorPan, SubPlot);

                imagesc(M{iM}.Ac(:, :, iFeat));

                SubPlot = SetAxis(SubPlot, ColorMap);
                t = ylabel(num2str(iFeat));
                set(gca, ...
                    'Xtick', 1:size(M{iM}.Ac(:, :, iFeat), 2), ...
                    'Ytick', 1:size(M{iM}.Ac(:, :, iFeat), 1), ...
                    'Xticklabel', [], ...
                    'Yticklabel', [], ...
                    'tickdir', 'out');
                set(t, 'fontsize', FONTSIZE);

                %%
                subplot(nVerPan, nHorPan, SubPlot);

                imagesc(dGdtheta(:, :, iFeat));

                SubPlot = SetAxis(SubPlot, ColorMap);
                axis square;

                %%
                subplot(nVerPan, nHorPan, SubPlot);

                RDM = diag(c * dGdtheta(:, :, iFeat) * c');
                RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));
                imagesc(squareform(RDM));

                SubPlot = SetAxis(SubPlot, ColorMap);
                axis square;

            end

            mtit(M{iM}.name, ...
                 'fontsize', 12, ...
                 'xoff', 0, ...
                 'yoff', .035);

        end

    end

end

function SubPlot = SetAxis(SubPlot, ColorMap)

    set(gca, ...
        'Xtick', [], ...
        'Ytick', []);
    colormap(ColorMap);

    SubPlot = SubPlot + 1;

end
