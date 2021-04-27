function CreateFigureExceedanceProba(ExProba, Fam, Analysis, InputType, ModelType, FigDir, ROIs)
    %
    % Matrices plot for exceedance probability
    %
    % (C) Copyright 2020 Remi Gau

    Opt = SetDefaults();
    Opt = SetPlottingParameters(Opt);

    ConditionType = 'stim';
    if Opt.Targets
        ConditionType = 'target'; %#ok<*UNRCH>
    end

    ColorMapDir = fullfile(fileparts(which('map_luminance')), '..', 'mat_maps');
    load(fullfile(ColorMapDir, '1hot_iso.mat'));
    ColorMap = hot;

    NbROIs = numel(ROIs);

    for iFam = 1:numel(ExProba)

        XP = ExProba{iFam};

        NbFam = numel(Fam{1, iFam}{1}.names);

        for iAnalysis = 1:size(XP, 3)

            switch ModelType

                case '3X3'

                    if NbFam == 3
                        Mat2Plot = squeeze(XP(:, 3, iAnalysis, :) + ...
                                           XP(:, 1, iAnalysis, :));

                    elseif NbFam == 2
                        Mat2Plot = squeeze(XP(:, 1, iAnalysis, :));

                    end

                    yTickLabel = {['V_i VS T_i'; 'A_i VS T_i'; 'A_i VS V_i']
                                  ['V_c VS T_c'; 'A_c VS T_c'; 'A_c VS V_c']
                                  ['V VS T'; 'A VS T'; 'A VS V']};

                    Titles = {Analysis(:).name};

                case 'subset6X6'

                    Mat2Plot = squeeze(XP);

                    Titles = {Analysis(:).name};

                    yTickLabel = {Fam{1}{1}.names};

                case 'test'

                    Titles = {Analysis.name};

                    yTickLabel = {['Row 1'; 'Row 2'; 'Row 3']};

                    Mat2Plot = XP;

            end

            Mat2Plot;

            filename = ['model_comparison', ...
                        '_cdt-', ConditionType, ...
                        '_param-', lower(InputType), ...
                        '_analysis-', Analysis(iAnalysis).name, ...
                        '_nbFamilies-', num2str(NbFam)];

            Opt.Title = strrep(filename, '_', ' ');
            Opt = OpenFigure(Opt);

            colormap('gray');

            hold on;
            box off;

            imagesc(flipud(Mat2Plot), [0 1]);

            % add borders
            plot([.5 NbROIs + .5], [1.5 1.5], 'color', [.2 .2 .2], 'linewidth', 1);
            plot([.5 NbROIs + .5], [2.5 2.5], 'color', [.2 .2 .2], 'linewidth', 1);
            for i = 1:NbROIs
                plot([0.5 0.5] + i, [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1);
            end

            patch([2.44 2.56 2.56 2.44], [.5 .5 3.5 3.5], 'w', 'linewidth', 2);

            plot([.5 .5], [.5 3.5], 'k', 'linewidth', 2);
            plot([NbROIs + .5 NbROIs + .5], [.5 3.5], 'k', 'linewidth', 2);
            plot([.5 NbROIs + .5], [.5 .5], 'k', 'linewidth', 2);
            plot([.5 NbROIs + .5], [3.5 3.5], 'k', 'linewidth', 2);

            title(Titles{iAnalysis});

            set(gca, 'fontsize', Opt.Fontsize, ...
                'ytick', 1:3, ...
                'yticklabel', yTickLabel{iAnalysis}, ...
                'xtick', 1:NbROIs, ...
                'xticklabel', ROIs(1:NbROIs), 'Xcolor', 'k');

            colorbar;

            axis([.5 NbROIs + .5 .5 3.5]);
            axis square;

            colormap(ColorMap);

            mtit([Opt.Title ' - ' InputType], ...
                 'fontsize', Opt.Fontsize, ...
                 'xoff', 0, 'yoff', .025);

            PrintFigure(FigDir);

        end

    end

end
