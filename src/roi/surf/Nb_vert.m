%%
clc;
clear;

StartDir = fullfile(pwd, '..', '..');

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

ROIs(1) = struct('name', 'A1', 'NbVertices', []);
ROIs(end + 1) = struct('name', 'PT', 'NbVertices', []);
ROIs(end + 1) = struct('name', 'V1', 'NbVertices', []);
ROIs(end + 1) = struct('name', 'V2', 'NbVertices', []);
ROIs(end + 1) = struct('name', 'V3', 'NbVertices', []);
ROIs(end + 1) = struct('name', 'V4', 'NbVertices', []);
ROIs(end + 1) = struct('name', 'V5', 'NbVertices', []);

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);

    %% Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    for iROI = 1:numel(ROIs)
        Idx = find(strcmp(ROIs(iROI).name, {ROI.name}'));
        ROIs(iROI).NbVertices(iSub, 1) = sum(cellfun('length', ROI(Idx).VertOfInt)); %#ok<*SAGROW>
    end

end

for iROI = 1:numel(ROIs)
    ROIs(iROI).MinVert = floor(min(ROIs(iROI).NbVertices) / 100) * 100;
    MinVert = ROIs;
end
mkdir(fullfile(StartDir, 'results', 'roi'));
save(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

return

%%
% ResultsFolder = fullfile(StartFolder,'Figures','8_layers');
%
% COLOR_Subject = ColorSubject()
%
% FigDim = [100 100 1800 1000];
%
% Visible = 'off';
%
% SubPlots = {[1 2 6 7], 3, 8, 4, 9, 5, 10};
%
% for iROI=1:7:numel(ROI)
%
%
%     %%
%     figure('name', [ROI(iROI).name '- ROI'], 'Position', [100, 100, 1500, 1000], ...
%         'Color', [1 1 1], 'Visible', Visibility);
%
%     MAX = cat(2,ROIs(iROI:iROI+6).NbVertices);
%     MAX = max(MAX(:));
%
%     for i=iROI:iROI+6
%
%         LEGEND={ROIs(i).name}';
%
%         subplot(2,5,SubPlots{i-(iROI)+1})
%
%         hold on
%
%         errorbar(1,mean(ROIs(i).NbVertices), nansem(ROIs(i).NbVertices), '.k')
%
%         for iSubj=1:size(SubjectList,1)
%             plot(1+.1*iSubj,ROIs(i).NbVertices(iSubj), 'marker', '.', 'markersize', 30, ....
%                 'color', COLOR_Subject(iSubj,:))
%         end
%
%         axis([0.9 2.3 0 MAX])
%
%         set(gca,'xtick',1+.1*(1:size(SubjectList,1)), 'xticklabel', SubjectList, 'ygrid', 'on',...
%             'fontsize', 8)
%
%         title(strrep(LEGEND, '_', '-'))
%
%     end
%
%     print(gcf, fullfile(ResultsFolder, [ROIs(iROI).name '_NbVertices.tif']), '-dtiff')
%
%
% end
%
