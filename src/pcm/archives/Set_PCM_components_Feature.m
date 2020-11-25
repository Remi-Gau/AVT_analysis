function [Components, h] = Set_PCM_components_Feature(print, FigDim)

    if nargin < 2 || isempty(FigDim)
        FigDim = [100, 100, 1000, 1500];
    end

    CondNames = { ...
                 'A ipsi', 'A contra', ...
                 'V ipsi', 'V contra', ...
                 'T ipsi', 'T contra' ...
                };

    %% Set the different Pattern components using Features

    fprintf('Preparing Feature components\n');

    Features(1).name = 'IpsiContra-A';
    Features(1).Feature = [ ...
                           0.5 1 0 0 0 0]';
    Features(2).name = 'IpsiContra-V';
    Features(2).Feature = [ ...
                           0 0 0.5 1 0 0]';
    Features(3).name = 'IpsiContra-T';
    Features(3).Feature = [ ...
                           0 0 0 0 0.5 1]';

    Features(4).name = 'IpsiContra-All';
    Features(4).Feature = [ ...
                           0.5 1 0.5 1 0.5 1]';

    Features(5).name = 'IpsiContra-A-deact';
    Features(5).Feature = [ ...
                           -0.5 -1 0 0 0 0]';
    Features(6).name = 'IpsiContra-V-deact';
    Features(6).Feature = [ ...
                           0 0 -0.5 -1 0 0]';
    Features(7).name = 'IpsiContra-T-deact';
    Features(7).Feature = [ ...
                           0 0 0 0 -0.5 -1]';

    Features(8).name = 'A-act';
    Features(8).Feature = [ ...
                           1 1 0 0 0 0]';
    Features(9).name = 'V-act';
    Features(9).Feature = [ ...
                           0 0 1 1 0 0]';
    Features(10).name = 'T-act';
    Features(10).Feature = [ ...
                            0 0 0 0 1 1]';

    Features(11).name = 'A-deact';
    Features(11).Feature = [ ...
                            -1 -1 0 0 0 0]';
    Features(12).name = 'V-deact';
    Features(12).Feature = [ ...
                            0 0 -1 -1 0 0]';
    Features(13).name = 'T-deact';
    Features(13).Feature = [ ...
                            0 0 0 0 -1 -1]';

    %%
    Components(1).Feature = cat(2, Features(1).Feature);
    Components(end).name = [num2str(numel(Components)) '- IpsiContra-A'];

    Components(end + 1).Feature = cat(2, Features(2).Feature);
    Components(end).name = [num2str(numel(Components)) '- IpsiContra-V'];

    Components(end + 1).Feature = cat(2, Features(3).Feature);
    Components(end).name = [num2str(numel(Components)) '- IpsiContra-T'];

    Components(end + 1).Feature = cat(2, Features(4).Feature);
    Components(end).name = [num2str(numel(Components)) '- IpsiContra-All'];

    Components(end + 1).Feature = sum(cat(2, Features([1 6 7]).Feature), 2);
    Components(end).name = [num2str(numel(Components)) '- IpsiContra-A act + V deact + T deact'];

    Components(end + 1).Feature = sum(cat(2, Features([2 5 7]).Feature), 2);
    Components(end).name = [num2str(numel(Components)) '- IpsiContra-V act + A deact + T deact'];

    Components(end + 1).Feature = sum(cat(2, Features([8 12 13]).Feature), 2);
    Components(end).name = [num2str(numel(Components)) '- A act + V deact + T deact'];

    Components(end + 1).Feature = sum(cat(2, Features([9 11 13]).Feature), 2);
    Components(end).name = [num2str(numel(Components)) '- V act + A deact + T deact'];

    if print

        %% Print the Features
        [nVerPan, nHorPan] = rsa.fig.paneling(numel(Features));

        ColorMap = seismic(100);

        h(1) = figure('name', 'Features', 'Position', FigDim, 'Color', [1 1 1]);

        for iFeat = 1:numel(Components)

            subplot(nVerPan, nHorPan, iFeat);

            colormap(ColorMap);

            imagesc(Components(iFeat).Feature, [-1 1]);

            axis on;
            set(gca, 'tickdir', 'out', 'xtick', 1:6, 'xticklabel', [], ...
                'ytick', 1:6, 'yticklabel', CondNames, ...
                'ticklength', [0.01 0], 'fontsize', 6);
            box off;

            colorbar;

            t = title(Components(iFeat).name);
            set(t, 'fontsize', 8);
        end

        mtit(h(1), 'Features', 'fontsize', 10, 'xoff', 0, 'yoff', .035);

        %% Print the G matrices
        [nVerPan, nHorPan] = rsa.fig.paneling(numel(Features));

        ColorMap = seismic(100);

        h(2) = figure('name', 'Components', 'Position', FigDim, 'Color', [1 1 1]);

        for iCpt = 1:numel(Components)

            subplot(nVerPan, nHorPan, iCpt);

            colormap(ColorMap);

            Feature = Components(iCpt).Feature;
            Components(iCpt).G = Feature * Feature';
            [~, p] = chol(Components(iCpt).G);
            if p > 0
                tmp = Components(iCpt).G;
                Components(iCpt).G = pcm_makePD(Components(iCpt).G);
                warning('Non PD G matrix.\nDifference from the original matrix=');
                disp(tmp - Components(iCpt).G);
            end

            imagesc(Components(iCpt).G, [-1 1.2]);

            axis on;
            set(gca, 'tickdir', 'out', 'xtick', 1:6, 'xticklabel', [], ...
                'ytick', 1:6, 'yticklabel', CondNames, ...
                'ticklength', [0.01 0], 'fontsize', 6);
            box off;
            axis square;

            colorbar;

            t = title(Components(iCpt).name);
            set(t, 'fontsize', 8);
        end

        mtit(h(2), 'Pattern components: G matrices', 'fontsize', 10, 'xoff', 0, 'yoff', .035);

        %% Print the RDM

        c = [ ...
             1 -1 0 0 0 0; ...
             1 0 -1 0 0 0; ...
             1 0 0 -1 0 0; ...
             1 0 0 0 -1 0; ...
             1 0 0 0 0 -1; ...
             0 1 -1 0 0 0; ...
             0 1 0 -1 0 0; ...
             0 1 0 0 -1 0; ...
             0 1 0 0 0 -1; ...
             0 0 1 -1 0 0; ...
             0 0 1 0 -1 0; ...
             0 0 1 0 0 -1; ...
             0 0 0 1 -1 0; ...
             0 0 0 1 0 -1; ...
             0 0 0 0 1 -1 ...
            ];

        ColorMap = brain_colour_maps('hot_increasing');

        [nVerPan, nHorPan] = rsa.fig.paneling(numel(Features));

        h(3) = figure('name', 'RDMs', 'Position', FigDim, 'Color', [1 1 1]);

        for iCpt = 1:numel(Components)

            subplot(nVerPan, nHorPan, iCpt);

            colormap(ColorMap);

            G = Components(iCpt).G;
            RDM = diag(c * G * c');

            RDM = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM, 1));

            imagesc(squareform(RDM));

            axis on;
            set(gca, 'tickdir', 'out', 'xtick', 1:6, 'xticklabel', [], ...
                'ytick', 1:6, 'yticklabel', CondNames, ...
                'ticklength', [0.01 0], 'fontsize', 6);
            box off;
            axis square;

            colorbar;

            t = title(Components(iCpt).name);
            set(t, 'fontsize', 8);
        end

        mtit(h(3), 'Pattern components: RDMs', 'fontsize', 10, 'xoff', 0, 'yoff', .035);

        % print(h(1), fullfile(Fig_dir, 'PCM_features.tif'), '-dtiff');
        % print(h(2), fullfile(Fig_dir, 'PCM_G_matrix.tif'), '-dtiff');
        % print(h(3), fullfile(Fig_dir, 'PCM_RDMs.tif'), '-dtiff');
        %
        % print(h(1), fullfile(Fig_dir, 'PCM_features.jpg'), '-djpeg');
        % print(h(2), fullfile(Fig_dir, 'PCM_G_matrix.jpg'), '-djpeg');
        % print(h(3), fullfile(Fig_dir, 'PCM_RDMs.jpg'), '-djpeg');

    end

end
