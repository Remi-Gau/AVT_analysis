function [Models_A, Models_V, h] = Set_PCM_models(Components, print, FigDim)

    h = [];

    CondNames = { ...
                 'A contra', 'A ipsi', ...
                 'V contra', 'V ipsi', ...
                 'T contra', 'T ipsi' ...
                };

    fprintf('Preparing the different models\n');

    %     '1-Sensory modalities'
    %     '2-A stim'
    %     '3-V stim'
    %     '4-T stim'
    %     '5-Non Preferred_A'
    %     '6-Non Preferred_V'
    %     '7-Ipsi Contra'
    %     '8-Ipsi Contra_{VT}'
    %     '9-Ipsi Contra_{A}'
    %     '10-Ipsi Contra_{AT}'
    %     '11-Ipsi Contra_{V}'

    %%
    Models_A(1).Cpts = [1];
    Models_A(end + 1).Cpts = [2];
    Models_A(end + 1).Cpts = [3];

    Models_A(end + 1).Cpts = [4];

    Models_A(end + 1).Cpts = [5];

    Models_A(end + 1).Cpts = [7];

    %%
    Models_V(1).Cpts = [1];
    Models_V(end + 1).Cpts = [2];
    Models_V(end + 1).Cpts = [3];

    Models_V(end + 1).Cpts = [4];

    Models_V(end + 1).Cpts = [6];

    Models_V(end + 1).Cpts = [8];

    %%

    if print
        h(1) = figure('name', 'Models ROI_A', 'Position', FigDim, 'Color', [1 1 1]);
        [nVerPan, nHorPan] = rsa.fig.paneling(numel(Models_A));
        for iMod = 1:numel(Models_A)

            mat = sum(cat(3, Components(Models_A(iMod).Cpts).G), 3);

            subplot(nVerPan, nHorPan, iMod);

            colormap('gray');

            imagesc(mat);

            axis on;
            set(gca, 'tickdir', 'out', 'xtick', 1:6, 'xticklabel', [], ...
                'ytick', 1:6, 'yticklabel', CondNames, ...
                'ticklength', [0.01 0], 'fontsize', 4);
            box off;
            axis square;

            Title = strrep(num2str(Models_A(iMod).Cpts), '  ', ' ');
            Title = strrep(Title, '  ', ' ');
            t = title(strrep(Title, ' ', '+'));
            set(t, 'fontsize', 6);

        end
        mtit('Models for auditory ROIs', 'fontsize', 12, 'xoff', 0, 'yoff', .035);

        h(2) = figure('name', 'Models ROI_V', 'Position', FigDim, 'Color', [1 1 1]);
        [nVerPan, nHorPan] = rsa.fig.paneling(numel(Models_V));
        for iMod = 1:numel(Models_V)

            mat = sum(cat(3, Components(Models_V(iMod).Cpts).G), 3);

            subplot(nVerPan, nHorPan, iMod);

            colormap('gray');

            imagesc(mat);

            axis on;
            set(gca, 'tickdir', 'out', 'xtick', 1:6, 'xticklabel', [], ...
                'ytick', 1:6, 'yticklabel', CondNames, ...
                'ticklength', [0.01 0], 'fontsize', 4);
            box off;
            axis square;

            Title = strrep(num2str(Models_V(iMod).Cpts), '  ', ' ');
            Title = strrep(Title, '  ', ' ');
            t = title(strrep(Title, ' ', '+'));
            set(t, 'fontsize', 6);

        end
        mtit('Models for visual ROIs', 'fontsize', 12, 'xoff', 0, 'yoff', .035);

    end

end
