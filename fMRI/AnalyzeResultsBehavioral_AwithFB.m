%%
clc; clear all; close all;

addpath(fullfile(pwd,'subfun'))

% Subjects = [4:6 8:10 12:13 15:18];
Subjects = [7 14];
% Subjects = [1 2];

FigDim = [100 100 1200 550];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

mn = length(Subjects);
n  = round(mn^0.4);
m  = ceil(mn/n);

ColorSubjects =   [...
    166,206,227;...
    31,120,180;...
    178,223,138;...
    51,160,44;...
    251,154,153;...
    227,26,28;...
    253,191,111;...
    255,127,0;...
    202,178,214;...
    106,61,154;...
    255,255,153;...
    177,89,40];
ColorSubjects=ColorSubjects/255;

h(1) = figure('name', 'Audio localization: Resp per loc - A', 'position', FigDim);

for SubjInd = 1:length(Subjects)
    
    clear Accuracy AccuracyLeft AccuracyRight AccComp
    
    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'PsyPhy'))
    
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
        AudioSide(AudioSide==8) = 0;
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
        
        NbResp = sum(strcmp('1', Stim_Time{1,1}) + strcmp('2', Stim_Time{1,1}) + strcmp('3', Stim_Time{1,1}));

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
            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) || strcmp('3', Stim_Time{1,1}(i,:))
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
        
        AudLocResp(AudLocResp==1)=-1;
        AudLocResp(AudLocResp==2)=0;
        AudLocResp(AudLocResp==3)=1;
        
        Data{iFile} = [AudioSide(1:length(AudLocResp)) AudLocResp AudLocRT];
        
        
        for i = -1:1
            tmp = Data{iFile}(Data{iFile}(:,1)==i,2);
            RespPerLoc(i+2,1,iFile) = sum(tmp==-1);
            RespPerLoc(i+2,2,iFile) = sum(tmp==0);
            RespPerLoc(i+2,3,iFile) = sum(tmp==1);
        end
        clear tmp
        
        Data{iFile}(isnan(Data{iFile}(:,2)),:)=[];
        
        Accuracy(iFile) = sum(Data{iFile}(:,1)==Data{iFile}(:,2))/size(Data{iFile},1) ;
        
        AccuracyLeft(iFile) = sum(Data{iFile}(Data{iFile}(:,1)==-1,1)==Data{iFile}(Data{iFile}(:,1)==-1,2))/sum(Data{iFile}(:,1)==-1) ;
        AccuracyCenter(iFile) = sum(Data{iFile}(Data{iFile}(:,1)==0,1)==Data{iFile}(Data{iFile}(:,1)==0,2))/sum(Data{iFile}(:,1)==1) ;
        AccuracyRight(iFile) = sum(Data{iFile}(Data{iFile}(:,1)==1,1)==Data{iFile}(Data{iFile}(:,1)==1,2))/sum(Data{iFile}(:,1)==1) ;
        
    end
    
     
    AccuracyAll(SubjInd,:) = [mean(Accuracy) mean(AccuracyLeft) mean(AccuracyCenter) mean(AccuracyRight)]
    
    
    %%

    SmoothWinWidth = 20;
    figure('name', ['Subject ' num2str(Subjects(SubjInd)) ' - Smoothing Window: ' num2str(SmoothWinWidth)], ...
    'position', FigDim)
    for iFile=1:size(Data,2)
        subplot(size(Data,2),1,iFile)
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
        set(gca, 'ytick', 0:.2:1, 'yticklabel',  0:.2:1)
        ylabel(['Accuracy run ' num2str(iFile)]);
        xlabel('Trials');
    end
    
    RespPerLoc = mean(RespPerLoc,3)
    RespPerLoc = RespPerLoc/sum(RespPerLoc(1,:));
    RespPerLocAll(:,:,SubjInd) = RespPerLoc;
    
    figure(h(1))
    subplot(m,n,SubjInd)
    colormap('hot')
    imagesc(RespPerLoc, [0 1])
    ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd))]));
    set(gca, 'ytick', 1:3, 'yticklabel', {}, ...
        'xtick', 1:3, 'xticklabel', {})

    
    
    %%
    cd(StartDirectory)
    
    clear Data Accuracy AccuracyLeft AccuracyCenter AccuracyRight RespPerLoc
    
end


figure('name', 'Audio localization', 'position', FigDim);
hold on
errorbar([0 2:4],  mean(AccuracyAll), nansem(AccuracyAll), ' o','LineWidth', 2)
plot([0 2:4], mean(AccuracyAll),'MarkerFaceColor',[0 0 1],'Marker','o','LineStyle','none',...
    'Color',[0 0 1], 'MarkerSize', 10)
for iSubj=1:size(AccuracyAll,1)
    plot([0 2:4]+.1+iSubj/20, AccuracyAll(iSubj,:),'MarkerFaceColor',ColorSubjects(iSubj,:),'Marker','o','LineStyle','none',...
    'Color',ColorSubjects(iSubj,:), 'MarkerSize', 5) 
end
axis([-0.5 5 0 1])
set(gca, 'ytick', 0:.25:1, 'yticklabel', 0:.25:1, 'xtick', 0:4, ...
    'xticklabel', {'AccTot','','AccLeft','AccCenter','AccRight'})
t=ylabel('Accuracy');


figure('name', 'MEAN - Audio localization: Resp per loc - A', 'position', FigDim);
colormap('hot')
imagesc(mean(RespPerLocAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
