function [model, fid] = ReturnLmmSpecAndData(Beta, Rois, Param, CdtNames, Cdts,  MakeFig, fid)
    %
    % (C) Copyright 2021 Remi Gau

    if nargin < 7
        fid = 1;
    end

    PrintModelDesciption(fid, Rois, Param, Cdts, CdtNames);

    Criteria = {Beta.Conditions, CdtNames(Cdts); ...
                Beta.Rois, Rois};

    RowsToSelect = ReturnRowsToSelect(Criteria);

    %% data
    Y = [];
    for sParam = 1:numel(Param)
        Y = [Y; Beta.(Param{sParam})(RowsToSelect)];
    end

    %% Design matrix and name of each regressor and rows
    SubjectVector  = repmat(Beta.Subjects(RowsToSelect), numel(Param), 1);

    Labels.Cdt = repmat(Beta.Conditions(RowsToSelect), numel(Param), 1);
    Labels.Rois = repmat(Beta.Rois(RowsToSelect), numel(Param), 1);

    Label.Sparam = [];
    RowLabels = [];
    for sParam = 1:numel(Param)
        Label.Sparam = [Label.Sparam; ones(sum(RowsToSelect), 1) * sParam];
        RowLabels = [RowLabels; repmat([Param{sParam} ' - '], sum(RowsToSelect), 1)];
    end

    X = [];
    RegNames = {};
    for sParam = 1:numel(Param)
        for iRoi = 1:numel(Rois)
            for iCdt = 1:numel(Cdts)

                RegNames{1, end + 1} = sprintf('%s_%s_%s', ...
                                               Param{sParam}, ...
                                               Rois{iRoi}, ...
                                               CdtNames{Cdts(iCdt)});

                Criteria = {Labels.Cdt, CdtNames(Cdts(iCdt)); ...
                            Labels.Rois, Rois{iRoi}; ...
                            Label.Sparam, sParam};
                X = [X ReturnRowsToSelect(Criteria)];

            end
        end
    end

    RowLabels = [RowLabels  char(Labels.Rois) repmat(' - ', size(X, 1), 1) char(Labels.Cdt)];
    SubjectRowLabels = [repmat(' - sub-', size(SubjectVector, 1), 1) num2str(SubjectVector)];
    RowLabels = [RowLabels SubjectRowLabels];

    model.X = X;
    model.Y = Y;
    model.RegNames = RegNames;
    model.RowLabels = RowLabels;

    % subjects as random effect
    model.G = SubjectVector;

    % random effect predictor: intercept
    model.Z = ones(size(X, 1), 1);

    if MakeFig
        PlotLmmSpecification(model);
    end

end

function PlotLmmSpecification(model)

    fontsize = 8;

    %% plot
    figure('name', 'LMM', 'position', [50 50 1500 1500]);
    colormap gray;

    subplot(1, 4, 1);
    imagesc(model.Y);
    set(gca, ...
        'ytick', 1:size(model.RowLabels, 1), ...
        'yticklabel', model.RowLabels, ...
        'fontsize', fontsize);
    title('data');

    subplot(1, 4, 2);
    imagesc(model.X);
    set(gca, ...
        'xtick', 1:numel(model.RegNames), ...
        'xticklabel', strrep(model.RegNames, '_', ' '), ...
        'XTickLabelRotation', 45, ...
        'fontsize', fontsize);
    title('X');

    subplot(1, 4, 3);
    imagesc(model.G);
    title('G: subjects');

    subplot(1, 4, 4);
    imagesc(model.Z);
    title('Z: intercept');

end

function PrintModelDesciption(fid, RoisToSelect, Parameters, Conditions, CdtNames)

    fprintf(fid, '\nMODEL');
    fprintf(fid, '\nROI: %s', strjoin(RoisToSelect));
    fprintf(fid, '\nConditions: %s ', strjoin(CdtNames(Conditions)));
    fprintf(fid, '\nParameters: %s \n', strjoin(Parameters));
end
