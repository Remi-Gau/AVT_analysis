%%
clc; clear; close all;

addpath(fullfile(pwd,'subfun'))

Subjects = 2 %[2 3 4 5 6 8 10 12 16];

Days = [...
    2  1 7 14 17; ...
    3  1 7 14 NaN; ...
    4  1 7 14 NaN; ...
    5  1 7 14 NaN; ...
    6  1 6 13 NaN; ...    
    8  1 7 14 NaN; ...
    10 1 7 14 NaN; ...
    12 1 6 13 NaN; ...
    16 1 6 NaN NaN];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

FigDim = [100 100 1200 550];

colors = 'rgbk';

for SubjInd = 1:numel(Subjects)
    
    clear Hits Miss FalseAlarms CorrectRejection ExtraResponses
    
    cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd)))))

    mkdir('Behavioral')

    copyfile('Logfile_*_Run_30*.txt', 'Behavioral')
    copyfile('Trial_List_Subject_*_Run_30*.txt', 'Behavioral')
    copyfile('Side_List_Subject_*_Run_30*.txt', 'Behavioral')

    cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd))), 'Behavioral'))

    LogFileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_30*.txt'));
    TrialListFileList = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_30*.txt'));
    
    
    for iFile = 1:length(LogFileList)
        
        % Loads trial type order presented
        TrialList = load(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        TrialList(TrialList==0) = [];
        
        disp(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt'])
        
        % Loads log file
        disp(LogFileList(iFile).name)
        
        fid = fopen(fullfile (pwd, LogFileList(iFile).name));
        FileContent = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', IndStart, 'returnOnError',0);
        fclose(fid);
        clear fid
        
        EOF = find(strcmp('Final_Fixation', FileContent{1,3}));
        if isempty(EOF)
            EOF = find(strcmp('Quit', FileContent{1,2})) - 1;
        end
        
        Stim_Time{1,1} = FileContent{1,3}(1:EOF);
        Stim_Time{1,2} = char(FileContent{1,4}(1:EOF));
        
        TEMP = find(strcmp('30', Stim_Time{1,1}));
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Target_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('PositiveFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('NegativeFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('BREAK', Stim_Time{1,1}))];
        
        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP
        
        NbATrial=sum(TrialList==1);
        NbVTrial=sum(TrialList==2);
        NbTTrial=sum(TrialList==5);
        NbATarget=sum(TrialList==6);
        NbVTarget=sum(TrialList==7);
        NbTTarget=sum(TrialList==8);
        
        NbResp=sum(strcmp('1', Stim_Time{1,1}))+...
            sum(strcmp('3', Stim_Time{1,1}))+...
            sum(strcmp('4', Stim_Time{1,1}))+...
            sum(strcmp('2', Stim_Time{1,1}));
        
        
        if numel(TrialList)~=sum (strcmp('AudioOnly_Trial_A', Stim_Time{1,1}) + ...
                strcmp('VisualOnly_Trial', Stim_Time{1,1}) + ...
                strcmp('Tactile_Trial', Stim_Time{1,1}) + ...
                strcmp('AudioOnly_Target_A', Stim_Time{1,1}) + ...
                strcmp('VisualOnly_Target', Stim_Time{1,1}) + ...
                strcmp('Tactile_Target', Stim_Time{1,1}))
            error('Missing some trials')
        end
        
        Hits(iFile,:) = zeros(1,3);
        Miss(iFile,:) = zeros(1,3);
        FalseAlarms(iFile,:) = zeros(1,3);
        CorrectRejection(iFile,:) = zeros(1,3);
        ExtraResponses(iFile,:) = zeros(1,3);
        
        IsTrial = 0;
        IsTarget = 0;
        
        j=1;
        
        for i=1:length(Stim_Time{1,1})
            
            if strcmp('AudioOnly_Trial_A', Stim_Time{1,1}(i,:))
                IsTrial = 1;
                IsTarget = 0;
                j=1;
            elseif strcmp('VisualOnly_Trial', Stim_Time{1,1}(i,:))
                IsTrial = 1;
                IsTarget = 0;
                j=2;
            elseif strcmp('Tactile_Trial', Stim_Time{1,1}(i,:))
                IsTrial = 1;
                IsTarget = 0;
                j=3;
                
            elseif strcmp('AudioOnly_Target_A', Stim_Time{1,1}(i,:))
                IsTrial = 0;
                IsTarget = 1;
                j=1;
            elseif strcmp('VisualOnly_Target', Stim_Time{1,1}(i,:))
                IsTrial = 0;
                IsTarget = 1;
                j=2;
            elseif strcmp('Tactile_Target', Stim_Time{1,1}(i,:))
                IsTrial = 0;
                IsTarget = 1;
                j=3;
            end
            
            if strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('3', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) || strcmp('4', Stim_Time{1,1}(i,:))
                if IsTrial
                    FalseAlarms(iFile,j)=FalseAlarms(iFile,j)+1;
                elseif IsTarget
                    Hits(iFile,j)=Hits(iFile,j)+1;
                else
                    ExtraResponses(iFile,j)=ExtraResponses(iFile,j)+1;
                end
                IsTrial = 0;
                IsTarget = 0;
            end
            
        end
        
        if sum(FalseAlarms(iFile,:)+Hits(iFile,:)+ExtraResponses(iFile,:)) ~= NbResp
            error('We are missing some responses.')
        end
        
        
        Hits;
        Miss(end,:) = [NbATarget NbVTarget NbTTarget] - Hits(iFile,:);
        FalseAlarms;
        CorrectRejection(end,:) =  [NbATrial NbVTrial NbTTrial] - FalseAlarms(iFile,:);
        
    end
    
    Hits = [Hits, sum(Hits,2)];
    Miss = [Miss, sum(Miss,2)];
    FalseAlarms = [FalseAlarms, sum(FalseAlarms,2)];
    CorrectRejection = [CorrectRejection, sum(CorrectRejection,2)];
    ExtraResponses = [ExtraResponses, sum(ExtraResponses,2)];
    
    for iFile = 1:size(Hits,1)
        fprintf('\nRun %i\tAudio\tVisual\tTactile\tTotal\n',iFile)
        fprintf('Hits\t %i\t %i\t %i\t %i\n', Hits(iFile,:))
        fprintf('Misses\t %i\t %i\t %i\t %i\n', Miss(iFile,:))
        fprintf('FA\t %i\t %i\t %i\t %i\n', FalseAlarms(iFile,:))
        fprintf('CR\t %i\t %i\t %i\t %i\n', CorrectRejection(iFile,:))
        
        fprintf('Extra responses %i\n', sum(ExtraResponses(iFile,:)))
    end
    
    if size(Hits,1)>1
        fprintf('\nTOTAL\tAudio\tVisual\tTactile\tTotal\n')
        fprintf('Hits\t %i\t %i\t %i\t %i\n', sum(Hits))
        fprintf('Misses\t %i\t %i\t %i\t %i\n', sum(Miss))
        fprintf('FA\t %i\t %i\t %i\t %i\n', sum(FalseAlarms))
        fprintf('CR\t %i\t %i\t %i\t %i\n', sum(CorrectRejection))
        fprintf('Extra responses %i\n', sum(ExtraResponses(iFile,:)))
    end
    
    Accuracy = round([(Hits+CorrectRejection)./(Hits+Miss+CorrectRejection+FalseAlarms)]*100);
    
    FalseAlarmRate = FalseAlarms./(FalseAlarms+CorrectRejection);
    HitRate = Hits./(Hits+Miss);
    
    D_prime = nan(size(HitRate));
    
    for i=1:numel(FalseAlarmRate)
        
        if FalseAlarmRate(i)==1
            FA_rate_tmp = 1 - 1/(2*(CorrectRejection(i)+FalseAlarms(i)));
        elseif FalseAlarmRate(i)==0
            FA_rate_tmp = 1/(2*(CorrectRejection(i)+FalseAlarms(i)));
        else
            FA_rate_tmp =  FalseAlarmRate(i);
        end
        
        if HitRate(i)==1
            HR_rate_tmp = 1 - 1/(2*((Hits(i)+Miss(i))));
        elseif HitRate(i)==0
            HR_rate_tmp = 1/(2*((Hits(i)+Miss(i))));
        else
            HR_rate_tmp = HitRate(i);
        end
        
        D_prime(i) = norminv(HR_rate_tmp)-norminv(FA_rate_tmp);
        
    end
    
    D_prime(:,end) = mean(D_prime(:,1:end-1),2);
    
    
    %%
    figure('name', 'AVT: hit rate', 'position', FigDim);
    
    subplot(1,3,1)
    if size(HitRate,1)>1
        bar([0:2 4], mean(HitRate*100))
    else
        bar([0:2 4], HitRate*100)
    end
    grid on
    axis([-1 5 0 100]);
    set(gca, 'ytick', 0:25:100, 'yticklabel', 0:25:100, 'xtick', 0:4, ...
        'xticklabel', {'A','V','T', '', 'Total'})
    ylabel(sprintf(['Hit rate\nSubject  ', num2str(Subjects(SubjInd))]));
    
    subplot(1,3,2:3)
    hold on
    bar(Miss(:,end)./(Miss(:,end)+Hits(:,end))*100)
    for i=1:size(HitRate,2)
        plot(1:size(HitRate,1), HitRate(:,i)*100, colors(i), 'linewidth', 2 );
    end
    t=legend(char({'Missed';'Audio';'Visual';'Tactile';'Total'}), 'Location', 'SouthWest');
    set(t, 'FontSize', 12)
    
    for iDay=1:3
        X = Days(Days(:,1)==Subjects(SubjInd),iDay+1);
        plot([X-.5 X-.5],[0 101],'k','LineWidth',2)
        t = text(X, 102, ['Day ' num2str(iDay)]);
        set(t, 'FontSize', 12)
    end
    
    xlabel('Run')
    grid on
    axis([0 size(Accuracy,1)+1 0 110]);
    set(gca, 'ytick', 0:10:100, 'yticklabel', 0:10:100, ...
        'xtick', 1:size(Accuracy,1),'xticklabel', 1:size(Accuracy,1))
    
    
        print(gcf, strcat('Subject_', sprintf('%02.0f', Subjects(SubjInd)), ...
        '_Hit_Rate.tif'), '-dtiff')
    
    
    %%
    figure('name', 'AVT: D prime', 'position', FigDim);
    
    subplot(1,3,1)
    if size(D_prime,1)>1
        bar([0:2 4], mean(D_prime))
    else
        bar([0:2 4], D_prime)
    end
    grid on
    axis([-1 5 0 4]);
    set(gca, 'ytick', 0:1:5, 'yticklabel', 0:1:5, 'xtick', 0:4, ...
        'xticklabel', {'A','V','T', '', 'Total'})
    ylabel(['Subject  ', num2str(Subjects(SubjInd))]);
    
    subplot(1,3,2:3)
    hold on
    for i=1:size(D_prime,2)
        plot(1:size(D_prime,1), D_prime(:,i), colors(i), 'linewidth', 2 );
    end
    t = legend(char({'Audio';'Visual';'Tactile';'Total'}), 'Location', 'SouthWest');
    set(t, 'FontSize', 12)
    
    for iDay=1:3
        X = Days(Days(:,1)==Subjects(SubjInd),iDay+1);
        plot([X-.5 X-.5],[0 4],'k','LineWidth',2)
        t = text(X, 4.05, ['Day ' num2str(iDay)]);
        set(t, 'FontSize', 12)
    end
    
    xlabel('Run')
    grid on
    axis([0 size(D_prime,1)+1 0 4.1]);
    set(gca, 'ytick', 0:1:5, 'yticklabel', 0:1:5, ...
        'xtick', 1:size(Accuracy,1),'xticklabel', 1:size(Accuracy,1))
    
    print(gcf, strcat('Subject_', sprintf('%02.0f', Subjects(SubjInd)), ...
        '_D_prime.tif'), '-dtiff')
    
    %%
    set(0,'units','pixels')
    Pix_SS = get(0,'screensize');
    
    Happy = imread(fullfile(StartDirectory,'Happy.jpg'));
    Neutral = imread(fullfile(StartDirectory,'Neutral.jpg'));
    Bad = imread(fullfile(StartDirectory,'Sad.jpg'));
    
    Ear = imread(fullfile(StartDirectory,'Ear.jpeg'));
    Eye = imread(fullfile(StartDirectory,'Eye.jpg'));
    Hand = imread(fullfile(StartDirectory,'Hand.jpg'));
    
    Green = [81 176 50]/255;
    Yellow = [255 238 0]/255;
    Red = [230 40 40]/255;
    
    figure('name', 'Perf AVT: last run', 'Color', [0 0 0], 'position', ...
        [100 -200 1700 800]);
    
    
    for i=1:3
        
        ToPlot = [Hits(end,i)/(Hits(end,i)+Miss(end,i)) ...
            Miss(end,i)/(Hits(end,i)+Miss(end,i)); ...
            FalseAlarms(end,i) ...
            0 ... %CorrectRejection(end,i)/(CorrectRejection(end,i)+FalseAlarms(end,i)) ...
            ];
        
        % Pictogram
        SubPLot = 1+(i-1);
        subplot(3,6,[SubPLot+i-1:SubPLot+i])
        
        if i==1
            image(Ear)
            t=title('Auditory');
        elseif i==2
            image(Eye)
            t=title('Visual');
        else
            image(Hand)
            t=title('Tactile');
        end
        set(t, 'FontSize', 16, 'Color',[1 1 1]);
        axis('off')
        axis('square')
        
        
        % Smiley
        SubPLot=SubPLot+6;
        subplot(3,6,[SubPLot+i-1:SubPLot+i])
        
        if ToPlot(2,1)>=2 || ToPlot(1)<.85
            image(Bad)
        elseif ToPlot(2,1)>=1 || ToPlot(1)<.9
            image(Neutral)
        else
            image(Happy)
        end
        
        axis('off')
        axis('square')
        
        
        % Performance
        SubPLot=SubPLot+6;
        subplot(3,6,SubPLot+i-1)
        hold on
        
        bar1 = bar(1:2, ToPlot, 'stacked');
        if ToPlot(1)<.85
            set(bar1(1),'FaceColor',[0 0 1],'EdgeColor',[1 1 1]);
            set(bar1(2),'FaceColor',Red,'EdgeColor',[1 1 1]);
        elseif ToPlot(1)<.9
            set(bar1(1),'FaceColor',[0 0 1],'EdgeColor',[1 1 1]);
            set(bar1(2),'FaceColor',Yellow,'EdgeColor',[1 1 1]);
        else
            set(bar1(1),'FaceColor',Green,'EdgeColor',[1 1 1]);
            set(bar1(2),'FaceColor',Green,'EdgeColor',[1 1 1]);
        end
        
        plot([.6 1.4], [.9 .9], '--k', 'linewidth', 4)
        
        set(gca,'XColor',[1 1 1],'XTick',[1],'XTickLabel',{'Hits'},...
            'YColor',[1 1 1], 'YTick',linspace(0,1,5), 'YTickLabel', linspace(0,Hits(end,1)+Miss(end,1),5),...
            'FontSize', 16);
        axis([.5 1.5 -.1 1.1])
        
        
        subplot(3,6,SubPLot+i)
        hold on
        
        bar1 = bar(1:2, ToPlot, 'stacked');
        if ToPlot(2,1)>=2
            set(bar1(1),'FaceColor',Red,'EdgeColor',[1 1 1]);
            set(bar1(2),'FaceColor',Red,'EdgeColor',[1 1 1]);
        elseif ToPlot(2,1)>=1
            set(bar1(1),'FaceColor',Yellow,'EdgeColor',[1 1 1]);
            set(bar1(2),'FaceColor',Yellow,'EdgeColor',[1 1 1]);
        else
            set(bar1(1),'FaceColor',Green,'EdgeColor',[1 1 1]);
            set(bar1(2),'FaceColor',Green,'EdgeColor',[1 1 1]);
        end
        
        plot([1.6 2.4], [2 2], '--k', 'linewidth', 4)
        
        set(gca,'XColor',[1 1 1],'XTick',[2],'XTickLabel',{'False Alarms'},...
            'YColor',[1 1 1], 'YTick',[0:1:10], 'YTickLabel',[0:1:10], 'FontSize', 16);
        axis([1.5 2.5 -.3 3.3])
        
    end
    
    return
    
    %%
    cd(StartDirectory)
    
end
