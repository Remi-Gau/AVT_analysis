%%
clc; clear all; close all;

Subjects = [10];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    clear Accuracy AccuracyLeft AccuracyRight AccComp

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd)))))

    for iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_100*.txt')))
        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_100', num2str(iFile) ,'*.txt'));
        TrialList = load(TEMP.name);

        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_100', num2str(iFile) ,'*.txt'));
        AudioSide = load(TEMP.name);
        AudioSide(AudioSide==2) = -1; AudioSide(AudioSide==3) = 1;


        % Loads log file
        LogFile = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_100', num2str(iFile) ,'*.txt'));

        disp(LogFile.name)

        fid = fopen(fullfile (pwd, LogFile.name));
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
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('PositiveFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('NegativeFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('BREAK', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AuditoryLocation', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        NbTrial=sum(strcmp('AudioOnly_Trial_A', Stim_Time{1,1}));

        AudLocResp = nan(NbTrial,1);
        AudLocRT = nan(NbTrial,1);

        iTrial = 0;

        for i=1:length(Stim_Time{1,1})
            if strcmp('AudioOnly_Trial_A', Stim_Time{1,1}(i,:))
                iTrial = iTrial+1;
                AudLoc = AudioSide(iTrial);
                TEMP1 = str2num(char(Stim_Time{1,2}(i,:)));
            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:))
                if AudLoc
                    AudLoc=0;
                    AudLocResp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                    AudLocRT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP1)/10000;
                end
            end
        end

        AudLocResp(AudLocResp==1)=-1;
        AudLocResp(AudLocResp==2)=1;

        Data{iFile} = [AudioSide(1:length(AudLocResp)) AudLocResp AudLocRT];

        Data{iFile}(isnan(Data{iFile}(:,2)),:)=[];

        Accuracy(iFile) = sum(Data{iFile}(:,1)==Data{iFile}(:,2))/size(Data{iFile},1) ;

        AccuracyLeft(iFile) = sum(Data{iFile}(Data{iFile}(:,1)==-1,1)==Data{iFile}(Data{iFile}(:,1)==-1,2))/sum(Data{iFile}(:,1)==-1) ;

        AccuracyRight(iFile) = sum(Data{iFile}(Data{iFile}(:,1)==1,1)==Data{iFile}(Data{iFile}(:,1)==1,2))/sum(Data{iFile}(:,1)==1) ;

%         AccComp(:,iFile) = Data{iFile}(:,1)==Data{iFile}(:,2);
    end

    %%
    figure('name', ['Subject ' num2str(Subjects(SubjInd))])
    for iFile=1:size(Data,2)
        subplot(size(Data,2),1,iFile)
        hold on
        grid on
        plot([Data{iFile}(:,1)==Data{iFile}(:,2)], 'b')

        set(gca, 'ytick', 0:1, 'yticklabel', ['0';'1'])
    end

    Accuracy
    AccuracyLeft
    AccuracyRight

    %%
    try
        AccComp = AccComp(:);

        Mean_Acc = mean(AccComp)
        STD_Acc = std(AccComp)

        MeanBoot =[];
        STD_MEAN = [];

        range = 10:10:190;

        for j=range
            for i=1:10000
                temp = randperm(length(AccComp));
                temp2(i)=mean(AccComp(temp(1:j)));
            end
            MeanBoot(end+1) = mean(temp2);
            STD_MEAN(end+1) = std(temp2);
        end

        figure('name', ['Subject ' num2str(Subjects(SubjInd))])
        hold on
        plot([1 max(range)+1], [Mean_Acc Mean_Acc],'b')
        %     plot([1 155], [Mean_Acc+STD_Acc Mean_Acc+STD_Acc],'--b')
        %     plot([1 155], [Mean_Acc-STD_Acc Mean_Acc-STD_Acc],'--b')
        plot(range, MeanBoot,'r')
        plot(range, MeanBoot+STD_MEAN,'--r')
        plot(range, MeanBoot-STD_MEAN,'--r')

        MeanBoot
        STD_MEAN
    catch
    end

    %%
    cd(StartDirectory)

end

