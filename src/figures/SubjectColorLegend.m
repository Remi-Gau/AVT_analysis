% (C) Copyright 2020 Remi Gau
[SubLs, NbSub] = GetSubjectList();
COLOR_SUBJECTS = SubjectColors();

figure(1);
hold on;
for iSubj = 1:NbSub
    plot([0 1], [iSubj iSubj], 'color', COLOR_SUBJECTS(iSubj, :), 'linewidth', 3);
end
axis([-.5 1.5 0  NbSub + 1]);
axis off;
legend({SubLs(:).name}, 'location', 'EastOutside');

print(gcf, fullfile(pwd, 'LegendSubjectColor.tif'), '-dtiff');
