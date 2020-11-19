%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

FigDim = [100 100 1200 550];

colors = 'rgbk';

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = [1:NbSub] % for each subject

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);
  mkdir(fullfile(SubDir, 'fig'));
  cd(fullfile(SubDir));

  % identify the number of sessions
  SesLs = dir('ses*');
  NbSes = numel(SesLs);

  % Initializes our next column
  Days = 1;
  Hits = [];
  Miss = [];
  FalseAlarms = [];
  CorrectRejection = [];
  ExtraResponses = [];

  RunInd = 1;
  for iSes = 1:NbSes % for each session

    % Gets all the runs for that session
    cd(fullfile(SubDir, SesLs(iSes).name, 'func'));

    % List log files
    TSV = dir('sub-*_ses-*_task-audiovisualtactile_run-*.tsv');

    for iRuns = 1:length(TSV)

      % Initializes our next column
      Hits(RunInd, :) = zeros(1, 3); %#ok<*SAGROW>
      Miss(RunInd, :) = zeros(1, 3);
      FalseAlarms(RunInd, :) = zeros(1, 3);
      CorrectRejection(RunInd, :) = zeros(1, 3);
      ExtraResponses(RunInd) = zeros(1, 1);

      % Read the onset file
      IFilefID = fopen(fullfile(SubDir, SesLs(iSes).name, 'func', TSV(iRuns).name));
      FileContent = textscan(IFilefID, '%f %s %s %s', 'headerlines', 1, 'Delimiter', '\t', ...
                             'returnOnError', 0);
      clear IFilefID;

      % Tabulates
      tmp = tabulate(FileContent{3});
      tmp2 = strcmp(tmp, 'AStimL');
      NbAStimL = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'VStimL');
      NbVStimL = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'TStimL');
      NbTStimL = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'ATargL');
      NbATargL = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'VTargL');
      NbVTargL = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'TTargL');
      NbTTargL = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'AStimR');
      NbAStimR = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'VStimR');
      NbVStimR = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'TStimR');
      NbTStimR = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'ATargR');
      NbATargR = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'VTargR');
      NbVTargR = tmp{tmp2, 2};
      tmp2 = strcmp(tmp, 'TTargR');
      NbTTargR = tmp{tmp2, 2};

      if NbAStimL + NbVStimL + NbTStimL + NbAStimR + NbVStimR + NbTStimR ~= 6 * 20
        error('We are missing some trials.');
      end

      if NbATargL + NbVTargL + NbTTargL + NbATargR + NbVTargR + NbTTargR ~= 6 * 5
        error('We are missing some targets.');
      end

      tmp2 = strcmp(tmp, 'Response');
      NbResponses = tmp{tmp2, 2};

      TrialType = 0; % Stim=1; Targ=2;
      IsResp = 0;
      SensMod = 0; % Audio=1; Visual=2; Tactile=3

      for i = 1:length(FileContent{1})

        % check if this is a trial, a target or a response
        if strcmp(FileContent{3}{i}(2:end - 1), 'Stim')
          TrialType = 1;
          IsResp = 0;
        elseif strcmp(FileContent{3}{i}(2:end - 1), 'Targ')
          TrialType = 2;
          IsResp = 0;
        elseif strcmp(FileContent{3}{i}(1:end), 'Response')
          IsResp = 1;
        end

        % if this is a trial or a target, we check the
        % sensory modality
        if IsResp == 0
          if strcmp(FileContent{3}{i}(1), 'A')
            SensMod = 1;
          elseif strcmp(FileContent{3}{i}(1), 'V')
            SensMod = 2;
          elseif strcmp(FileContent{3}{i}(1), 'T')
            SensMod = 3;
          end
        end

        if IsResp
          if TrialType == 1
            FalseAlarms(RunInd, SensMod) = FalseAlarms(RunInd, SensMod) + 1;
          elseif TrialType == 2
            Hits(RunInd, SensMod) = Hits(RunInd, SensMod) + 1;
          else
            ExtraResponses(RunInd) = ExtraResponses(RunInd) + 1;
          end
          TrialType = 0;
        end

      end

      FileContent = [];

      Miss(RunInd, :) = [NbATargL + NbATargR, NbVTargL + NbVTargR, NbTTargL + NbTTargR] - Hits(RunInd, :);
      CorrectRejection(RunInd, :) =  [NbAStimL + NbAStimR, NbVStimL + NbVStimR, NbTStimL + NbTStimR] - FalseAlarms(RunInd, :);

      if NbResponses ~= [sum(Hits(RunInd, :)) + sum(FalseAlarms(RunInd, :)) + ExtraResponses(RunInd)]
        error('We are missing some responses.');
      end

      RunInd = RunInd + 1;
    end

    Days(end + 1) = RunInd;

  end

  Days(end) = [];

  if strcmp(SubLs(iSub).name, 'sub-06')
    Hits(17, 1) = NaN;
    Miss(17, 1) = NaN;
  end

  Hits = [Hits, nansum(Hits, 2)];
  Miss = [Miss, nansum(Miss, 2)];
  FalseAlarms = [FalseAlarms, nansum(FalseAlarms, 2)];
  CorrectRejection = [CorrectRejection, nansum(CorrectRejection, 2)];

  for iFile = 1:size(Hits, 1)
    fprintf('\nRun %i\tAudio\tVisual\tTactile\tTotal\n', iFile);
    fprintf('Hits\t %i\t %i\t %i\t %i\n', Hits(iFile, :));
    fprintf('Misses\t %i\t %i\t %i\t %i\n', Miss(iFile, :));
    fprintf('FA\t %i\t %i\t %i\t %i\n', FalseAlarms(iFile, :));
    fprintf('CR\t %i\t %i\t %i\t %i\n', CorrectRejection(iFile, :));
    fprintf('Extra responses %i\n', sum(ExtraResponses(iFile)));
  end

  if size(Hits, 1) > 1
    fprintf('\nTOTAL\tAudio\tVisual\tTactile\tTotal\n');
    fprintf('Hits\t %i\t %i\t %i\t %i\n', sum(Hits));
    fprintf('Misses\t %i\t %i\t %i\t %i\n', sum(Miss));
    fprintf('FA\t %i\t %i\t %i\t %i\n', sum(FalseAlarms));
    fprintf('CR\t %i\t %i\t %i\t %i\n', sum(CorrectRejection));
    fprintf('Extra responses %i\n', sum(ExtraResponses(iFile)));
  end

  Accuracy = round([(Hits + CorrectRejection) ./ (Hits + Miss + CorrectRejection + FalseAlarms)] * 100);

  FalseAlarmRate = FalseAlarms ./ (FalseAlarms + CorrectRejection);
  HitRate = Hits ./ (Hits + Miss);

  D_prime = nan(size(HitRate));

  for i = 1:numel(FalseAlarmRate)

    if FalseAlarmRate(i) == 1
      FA_rate_tmp = 1 - 1 / (2 * (CorrectRejection(i) + FalseAlarms(i)));
    elseif FalseAlarmRate(i) == 0
      FA_rate_tmp = 1 / (2 * (CorrectRejection(i) + FalseAlarms(i)));
    else
      FA_rate_tmp =  FalseAlarmRate(i);
    end

    if HitRate(i) == 1
      HR_rate_tmp = 1 - 1 / (2 * (Hits(i) + Miss(i)));
    elseif HitRate(i) == 0
      HR_rate_tmp = 1 / (2 * (Hits(i) + Miss(i)));
    else
      HR_rate_tmp = HitRate(i);
    end

    D_prime(i) = norminv(HR_rate_tmp) - norminv(FA_rate_tmp);

  end

  D_prime(:, end) = nanmean(D_prime(:, 1:end - 1), 2);

  save(fullfile(SubDir, ['Behavior_' SubLs(iSub).name '.mat']), 'D_prime', 'CorrectRejection', 'Miss', 'Hits', ...
       'FalseAlarms');

  %%
  figure('name', 'AVT: hit rate', 'position', FigDim);

  subplot(1, 3, 1);
  if size(HitRate, 1) > 1
    bar([0:2 4], nanmean(HitRate * 100));
  else
    bar([0:2 4], HitRate * 100);
  end
  grid on;
  axis([-1 5 0 100]);
  set(gca, 'ytick', 0:25:100, 'yticklabel', 0:25:100, 'xtick', 0:4, ...
      'xticklabel', {'A', 'V', 'T', '', 'Total'});
  ylabel(sprintf(['Hit rate\nSubject  ', SubLs(iSub).name]));

  subplot(1, 3, 2:3);
  hold on;
  bar(Miss(:, end) ./ (Miss(:, end) + Hits(:, end)) * 100);
  for i = 1:size(HitRate, 2)
    plot(1:size(HitRate, 1), HitRate(:, i) * 100, colors(i), 'linewidth', 2);
  end
  t = legend(char({'Missed'; 'Audio'; 'Visual'; 'Tactile'; 'Total'}), 'Location', 'SouthWest');
  set(t, 'FontSize', 12);

  for iDay = 1:3
    X = Days(iDay);
    plot([X - .5 X - .5], [0 101], 'k', 'LineWidth', 2);
    t = text(X, 102, ['Day ' num2str(iDay)]);
    set(t, 'FontSize', 12);
  end

  xlabel('Run');
  grid on;
  axis([0 size(Accuracy, 1) + 1 0 110]);
  set(gca, 'ytick', 0:10:100, 'yticklabel', 0:10:100, ...
      'xtick', 1:size(Accuracy, 1), 'xticklabel', 1:size(Accuracy, 1));

  print(gcf, fullfile(SubDir, 'fig', strcat(SubLs(iSub).name, '_Hit_Rate.tif')), '-dtiff');

  %%
  figure('name', 'AVT: D prime', 'position', FigDim);

  subplot(1, 3, 1);
  if size(D_prime, 1) > 1
    bar([0:2 4], mean(D_prime));
  else
    bar([0:2 4], D_prime);
  end
  grid on;
  axis([-1 5 0 4]);
  set(gca, 'ytick', 0:1:5, 'yticklabel', 0:1:5, 'xtick', 0:4, ...
      'xticklabel', {'A', 'V', 'T', '', 'Total'});
  ylabel(sprintf(['d prime\nSubject  ', SubLs(iSub).name]));

  subplot(1, 3, 2:3);
  hold on;
  for i = 1:size(D_prime, 2)
    plot(1:size(D_prime, 1), D_prime(:, i), colors(i), 'linewidth', 2);
  end
  t = legend(char({'Audio'; 'Visual'; 'Tactile'; 'Total'}), 'Location', 'SouthWest');
  set(t, 'FontSize', 12);

  for iDay = 1:3
    X = Days(iDay);
    plot([X - .5 X - .5], [0 4], 'k', 'LineWidth', 2);
    t = text(X, 4.05, ['Day ' num2str(iDay)]);
    set(t, 'FontSize', 12);
  end

  xlabel('Run');
  grid on;
  axis([0 size(D_prime, 1) + 1 0 4.1]);
  set(gca, 'ytick', 0:1:5, 'yticklabel', 0:1:5, ...
      'xtick', 1:size(Accuracy, 1), 'xticklabel', 1:size(Accuracy, 1));

  print(gcf, fullfile(SubDir, 'fig', strcat(SubLs(iSub).name, '_D_prime.tif')), '-dtiff');

  close all;

  cd(StartDir);

end
