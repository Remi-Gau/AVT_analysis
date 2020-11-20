function fig_h = Plot_PCM_models_feature(M)

    ColorMap = brain_colour_maps('hot_increasing');

    FigDim = [100, 50, 1300, 700];

    for iM = 1:numel(M)

        if strcmp(M{iM}.type, 'feature')

            if isfield('theta0', M{iM})
                [G, dGdtheta] = pcm_calculateG(M{iM}, M{iM}.theta0);
            else
                [G, dGdtheta] = pcm_calculateG(M{iM}, ones(M{iM}.numGparams, 1));
            end

            c = pcm_indicatorMatrix('allpairs', 1:size(M{iM}.Ac, 1));

            fig_h(iM) = figure('name', M{iM}.name, 'Position', FigDim);

            SubPlot = 1;

            nVerPan = M{iM}.numGparams + 1;
            nHorPan = 3;

            subplot(nVerPan, nHorPan, SubPlot);
            imagesc(sum(M{iM}.Ac, 3));
            t = title('feature');
            set(t, 'fontsize', 6);
            SubPlot = SetAxis(SubPlot, ColorMap);
            t = ylabel('sum(features)');
            set(t, 'fontsize', 6);

            subplot(nVerPan, nHorPan, SubPlot);
            imagesc(G);
            SubPlot = SetAxis(SubPlot, ColorMap);
            axis square;
            t = title('dG dtheta');
            set(t, 'fontsize', 6);

            subplot(nVerPan, nHorPan, SubPlot);
            RDM = diag(c * G * c');
            RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));
            imagesc(squareform(RDM));
            SubPlot = SetAxis(SubPlot, ColorMap);
            axis square;
            t = title('RDM');
            set(t, 'fontsize', 6);

            for iFeat = 1:nVerPan - 1

                subplot(nVerPan, nHorPan, SubPlot);
                imagesc(M{iM}.Ac(:, :, iFeat));
                SubPlot = SetAxis(SubPlot, ColorMap);
                t = ylabel(num2str(iFeat));
                set(gca, 'Xtick', 1:size(M{iM}.Ac(:, :, iFeat), 2), 'Ytick', 1:size(M{iM}.Ac(:, :, iFeat), 1), ...
                    'Xticklabel', [], 'Yticklabel', [], 'tickdir', 'out');
                set(t, 'fontsize', 6);

                subplot(nVerPan, nHorPan, SubPlot);
                imagesc(dGdtheta(:, :, iFeat));
                SubPlot = SetAxis(SubPlot, ColorMap);
                axis square;

                subplot(nVerPan, nHorPan, SubPlot);
                RDM = diag(c * dGdtheta(:, :, iFeat) * c');
                RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));
                imagesc(squareform(RDM));
                SubPlot = SetAxis(SubPlot, ColorMap);
                axis square;

            end

            mtit(M{iM}.name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

        end

    end

end

function SubPlot = SetAxis(SubPlot, ColorMap)
    set(gca, 'Xtick', [], 'Ytick', []);
    colormap(ColorMap);
    % colorbar
    SubPlot = SubPlot + 1;
end
