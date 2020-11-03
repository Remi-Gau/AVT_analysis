% small script to remove any space in the filenames where the MVPA results are
% saved.

clc;
clear;

[Dirs, SubLs, NbSub] = set_dir();

for iSubj = 1:NbSub
  
  fprintf('\n\nProcessing %s', SubLs(iSubj).name);
  
  SubDir = fullfile(Dirs.DerDir, SubLs(iSubj).name);
  SaveDir = fullfile(SubDir, 'results', 'SVM');
  
  FileList = spm_select('List', SaveDir, '^*.mat$');
  
  for iFile = 1:size(FileList,1)
    movefile(...
      fullfile(SaveDir,        deblank(FileList(iFile,:))), ...
      fullfile(SaveDir, strrep(deblank(FileList(iFile,:)), ' ', '_')))
  end
  
end