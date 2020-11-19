clear;
clc;
close all;

StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
cd (StartDir);

ROIs = { ...
        'V1', ...
        'V2', ...
        'V3', ...
        'V4', ...
        'V5', ...
        'A1', ...
        'PT'
       };

% Options for the SVM
[opt, ~] = get_mvpa_options();

NbLayers = 6;

%%
MVPAFigDir =  fullfile(StartDir, 'figures', 'SVM', 'surf');
DestFigDir = fullfile(MVPAFigDir, 'compiled');
mkdir(DestFigDir);

for Perm = 0:1

  if Perm
    suffix = '_perm';
  else
    suffix = '_ttest';
  end

  for Norm = 6:8

    [opt] = ChooseNorm(Norm, opt);

    SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
    SaveSufix = strrep(SaveSufix, '_', '-');

    for iROI = 1:numel(ROIs)

      cd(MVPAFigDir);
      A = dir([strrep(ROIs{iROI}, '_', '-')  '-Contra-vs-Ipsi-' SaveSufix(9:end - 4)  suffix '.tif']);
      B = dir([strrep(ROIs{iROI}, '_', '-')  '-Contra-vs-Ipsi-' SaveSufix(9:end - 4) '_6Layers' suffix '.tif']);
      C = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Ipsi-' SaveSufix(9:end - 4)  suffix '.tif']);
      D = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Ipsi-' SaveSufix(9:end - 4) '_6Layers' suffix '.tif']);
      E = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Contra-' SaveSufix(9:end - 4)  suffix '.tif']);
      F = dir([strrep(ROIs{iROI}, '_', '-') '-Between-Senses-Contra-' SaveSufix(9:end - 4) '_6Layers' suffix '.tif']);

      Command = [];

      for iFile = 1:numel(A)
        disp(A(iFile).name);
        disp(B(iFile).name);
        disp(C(iFile).name);
        disp(D(iFile).name);
        disp(E(iFile).name);
        disp(F(iFile).name);

        Command = [Command ' ' fullfile(MVPAFigDir, A(iFile).name)]; %#ok<*AGROW>
        Command = [Command ' ' fullfile(MVPAFigDir, B(iFile).name)];
        Command = [Command ' ' fullfile(MVPAFigDir, C(iFile).name)];
        Command = [Command ' ' fullfile(MVPAFigDir, D(iFile).name)];
        Command = [Command ' ' fullfile(MVPAFigDir, E(iFile).name)];
        Command = [Command ' ' fullfile(MVPAFigDir, F(iFile).name)];

      end

      system(['convert ' Command ' ' fullfile(DestFigDir, ...
                                              [ROIs{iROI} '_AVT_MVPA_' SaveSufix(2:end - 4) suffix '_' date '.pdf'])]);
    end

  end

end
