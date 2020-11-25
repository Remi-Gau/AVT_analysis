SubLs = {
         'sub-02'
         'sub-03'
         'sub-04'
         'sub-05'
         'sub-06'
         'sub-08'
         'sub-10'
         'sub-12'
         'sub-16'
         'sub-19'};

NbSub = numel(SubLs);

COLOR_SUBJECTS = SubjectColours();

figure(1);
hold on;
for iSubj = 1:NbSub
    plot([0 1], [iSubj iSubj], 'color', COLOR_SUBJECTS(iSubj, :), 'linewidth', 3);
end
axis([-.5 1.5 0  NbSub + 1]);
axis off;
legend(SubLs, 'location', 'EastOutside');

print(gcf, fullfile(FigureFolder, 'LegendSubjectColor.tif'), '-dtiff');
