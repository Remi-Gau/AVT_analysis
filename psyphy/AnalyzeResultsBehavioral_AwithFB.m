%%
clc; clear all; close all;

addpath(fullfile(pwd,'subfun'))

Subjects = 19;

FigDim = [100 100 1200 550];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;



for SubjInd = 1:length(Subjects)

    clear Accuracy AccuracyLeft AccuracyRight AccComp

    cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd)))))

    mkdir('ALoc')

    copyfile('Logfile_*Run_110*.txt', 'ALoc')
    copyfile('Trial_List_Subject_*Run_110*.txt', 'ALoc')
    copyfile('Side_List_Subject_*Run_110*.txt', 'ALoc')

    cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd))), 'ALoc'))

    LogFileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_11*.txt'));

    for iFile = 1:length(LogFileList)

        RunNumber = LogFileList(iFile).name(end-23:end-20);

        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_', num2str(RunNumber) ,'*.txt'));
        TrialList = load(TEMP.name);

        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_', num2str(RunNumber) ,'*.txt'));
        AudioSide = load(TEMP.name);
        AudioSide(AudioSide==0) = [];
        AudioSide(AudioSide==4) = -1;
        AudioSide(AudioSide==12) = 1;

        % Loads log file
        LogFile = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_', num2str(RunNumber) ,'*.txt'));

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
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('PositiveFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('NegativeFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('4', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('BREAK', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AuditoryLocation', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        NbTrial=sum(strcmp('AudioOnly_Trial_A', Stim_Time{1,1}));

        if NbTrial~=sum(strcmp('AudioOnly_Trial_A', Stim_Time{1,1}))
            error('Missing some trials')
        end

        NbResp = sum(strcmp('1', Stim_Time{1,1}) + strcmp('2', Stim_Time{1,1}));

        AudLocResp = nan(NbTrial,1);
        AudLocRT = nan(NbTrial,1);

        iTrial = 0;
        IsTrial = 0;
        ExtraResp=0;

        for i=1:length(Stim_Time{1,1})
            if strcmp('AudioOnly_Trial_A', Stim_Time{1,1}(i,:))
                iTrial = iTrial+1;
                TEMP1 = str2num(char(Stim_Time{1,2}(i,:)));
                IsTrial = 1;
            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:))
                if IsTrial
                    AudLocResp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                    AudLocRT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP1)/10000;
                    IsTrial = 0;
                else
                    ExtraResp=ExtraResp+1;
                end
            end
        end

        if sum(~isnan(AudLocResp))+ExtraResp ~= NbResp
            error('We are missing some responses.')
        end

        AudLocResp(AudLocResp==1 )=-1;
        AudLocResp(AudLocResp==2)=1;

        Data{iFile} = [AudioSide(1:length(AudLocResp)) AudLocResp AudLocRT];
        Data{iFile}(isnan(Data{iFile}(:,2)),:)=[];

        tmp = Data{iFile}(Data{iFile}(:,1)==-1,2);
        Accuracy(1,iFile) = sum(tmp==-1)/sum(Data{iFile}(:,1)==-1);

        tmp = Data{iFile}(Data{iFile}(:,1)==1,2);
        Accuracy(2,iFile) = sum(tmp==1)/sum(Data{iFile}(:,1)==1);

    end


    %%
    SmoothWinWidth = 3;
    figure('name', ['Subject ' num2str(Subjects(SubjInd))], 'position', FigDim)

    for iFile=1:size(Data,2)

        subplot(size(Data,2),2,iFile*2-1)
        hold on
        grid on

        bar(1:2, Accuracy(:,iFile))

        ylabel(['Accuracy run ' num2str(iFile)]);
        set(gca, 'ytick', 0:.1:1, 'yticklabel', 0:.1:1, ...
            'xtick', 1:2, 'xticklabel', {'Links','Recht'})


        subplot(size(Data,2),2,iFile*2)
        hold on
        grid on

        SmoothedAcc = [Data{iFile}(:,1)==Data{iFile}(:,2)];

        for i=1:length(SmoothedAcc)-SmoothWinWidth+1
            tmp(i)=mean(SmoothedAcc(i:i+SmoothWinWidth-1));
        end
        SmoothedAcc = tmp;
        clear tmp

        plot(SmoothedAcc, 'b')

        axis([0 length(SmoothedAcc) 0 1])
        set(gca, 'ytick', 0:.1:1, 'yticklabel',  0:.1:1)
        xlabel('Trials');
    end

        print(gcf, strcat('Subject_', sprintf('%02.0f', Subjects(SubjInd)), ...
        '_A_Localization_with_feedback.tif'), '-dtiff')
    
    %%
    cd(StartDirectory)

    clear Data Accuracy AccuracyLeft AccuracyCenter AccuracyRight RespPerLoc

end

