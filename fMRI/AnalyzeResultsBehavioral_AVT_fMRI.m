%%
clc; clear all; close all;

addpath(fullfile(pwd,'subfun'))

Subjects = [1:3];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

FigDim = [100 100 1200 550];

h(1)=figure('name', 'AVT: Accuracy', 'position', FigDim);
h(2)=figure('name', 'AVT: D prime', 'position', FigDim);

Subplot=1;

colors = 'rgbk';

for SubjInd = 1:length(Subjects)
    
   clear Hits Miss FalseAlarms CorrectRejection ExtraResponses
    
    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'fMRI'))

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
    
    fprintf('Hits\n')
    Hits = [Hits, sum(Hits,2)];
    disp(sum(Hits))
    fprintf('Misses\n')
    Miss = [Miss, sum(Miss,2)];
    disp(sum(Miss))
    fprintf('False alarms\n')
    FalseAlarms = [FalseAlarms, sum(FalseAlarms,2)];
    disp(sum(FalseAlarms))
    fprintf('Correct rejection\n')
    CorrectRejection = [CorrectRejection, sum(CorrectRejection,2)];
    disp(sum(CorrectRejection))
    fprintf('Extra responses\n')
    ExtraResponses = [ExtraResponses, sum(ExtraResponses,2)];
    disp(sum(ExtraResponses))

    fprintf('\nAccuracy\n')
    Accuracy = round([(Hits+CorrectRejection)./(Hits+Miss+CorrectRejection+FalseAlarms)]*100);
    disp( mean(Accuracy))
    
    FalseAlarmRate = FalseAlarms./(FalseAlarms+CorrectRejection);
    HitRate = Hits./(Hits+Miss);
    
    D_prime = nan(size(HitRate));
    
    for i=1:numel(FalseAlarmRate)

            if FalseAlarmRate(i)==1
                FalseAlarmRate = 1 - 1/(2*(CorrectRejection(i)+FalseAlarms(i)));
            elseif FalseAlarmRate(i)==0
                FalseAlarmRate(i) = 1/(2*(CorrectRejection(i)+FalseAlarms(i)));
            end

            if HitRate(i)==1
                HitRate(i) = 1 - 1/(2*((Hits(i)+Miss(i))));
            elseif HitRate(i)==0
                HitRate(i) = 1/(2*((Hits(i)+Miss(i))));
            end
            
            D_prime(i) = norminv(HitRate(i))-norminv(FalseAlarmRate(i));

    end
    
    D_prime(:,end) = mean(D_prime(:,1:end-1),2);
    
    figure(h(1))
    subplot(numel(Subjects),3,Subplot)
    bar([0:2 4], mean(HitRate*100))
    grid on
    axis([-1 5 0 100]);
    set(gca, 'ytick', 0:25:100, 'yticklabel', 0:25:100, 'xtick', 0:4, ...
        'xticklabel', {'A','V','T', '', 'Total'})
    ylabel(sprintf(['Hit rate\nSubject  ', num2str(Subjects(SubjInd))]));
    
    figure(h(2))
    subplot(numel(Subjects),3,Subplot)
    bar([0:2 4], mean(D_prime))
    grid on
    axis([-1 5 0 4]);
    set(gca, 'ytick', 0:1:5, 'yticklabel', 0:1:5, 'xtick', 0:4, ...
        'xticklabel', {'A','V','T', '', 'Total'})
    ylabel(['Subject  ', num2str(Subjects(SubjInd))]);

    Subplot=Subplot+1;
    
    figure(h(1))
    subplot(numel(Subjects),3,[Subplot:Subplot+1])
    hold on
    bar(Miss(:,end)./(Miss(:,end)+Hits(:,end))*100)
    for i=1:size(Accuracy,2)
        plot(1:size(HitRate,1), HitRate(:,i)*100, colors(i));
    end
    t=legend(char({'Missed';'Audio';'Visual';'Tactile';'Total'}), 'Location', 'SouthWest');
    set(t, 'FontSize', 8)
    plot([5.5 5.5],[0 110],'k','LineWidth',2)
    xlabel('Run')
    grid on
    axis([-4 size(Accuracy,1)+1 0 110]);
    set(gca, 'ytick', 0:25:100, 'yticklabel', 0:25:100, ...
        'xtick', 1:size(Accuracy,1),'xticklabel', 1:size(Accuracy,1))
    
    figure(h(2))
    subplot(numel(Subjects),3,[Subplot:Subplot+1])
    hold on
    for i=1:size(D_prime,2)
        plot(1:size(D_prime,1), D_prime(:,i), colors(i));
    end
    t = legend(char({'Audio';'Visual';'Tactile';'Total'}), 'Location', 'SouthWest');
    set(t, 'FontSize', 8)
    
    plot([5.5 5.5],[0 5],'k','LineWidth',2)
    xlabel('Run')
    grid on
    axis([-4 size(D_prime,1)+1 0 4]);
    set(gca, 'ytick', 0:1:5, 'yticklabel', 0:1:5, ...
        'xtick', 1:size(Accuracy,1),'xticklabel', 1:size(Accuracy,1))

    Subplot=Subplot+2;


    cd(StartDirectory)

end


figure(h(1))
print(gcf, 'AVT_Accuracy.tif', '-dtiff')
figure(h(2))
print(gcf, 'AVT_DPrime.tif', '-dtiff')
