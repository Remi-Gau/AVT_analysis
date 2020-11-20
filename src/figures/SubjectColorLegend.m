StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

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

FigureFolder = fullfile(StartDir, 'figures', 'behavioral');
mkdir(FigureFolder);

COLOR_Subject = [
                 31, 120, 180
                 178, 223, 138
                 51, 160, 44
                 251, 154, 153
                 227, 26, 28
                 253, 191, 111
                 255, 127, 0
                 202, 178, 214
                 106, 61, 154
                 0, 0, 130];
COLOR_Subject = COLOR_Subject / 255;

figure(1);
hold on;
for iSubj = 1:NbSub
    plot([0 1], [iSubj iSubj], 'color', COLOR_Subject(iSubj, :), 'linewidth', 3);
end
axis([-.5 1.5 0  NbSub + 1]);
axis off;
legend(SubLs, 'location', 'EastOutside');

print(gcf, fullfile(FigureFolder, 'LegendSubjectColor.tif'), '-dtiff');
