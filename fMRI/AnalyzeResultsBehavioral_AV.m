%%
clc; clear all; close all;

Subjects = [10 11];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'PsyPhy'))

    for iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_200*.txt')))
        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_200', num2str(iFile) ,'*.txt'));
        TrialList = load(TEMP.name);

        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_200', num2str(iFile) ,'*.txt'));
        AudioSide = load(TEMP.name);
        AudioSide(AudioSide==2) = -1; AudioSide(AudioSide==3) = 1;

        VisualSide = AudioSide;
        VisualSide(TrialList==4) = VisualSide(TrialList==4)*-1;


        % Loads log file
        LogFile = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_200', num2str(iFile) ,'*.txt'));

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
        TEMP = [TEMP ; find(strcmp('AudioVisual_Inc_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Con_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Inc_Trial_A', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Con_Trial_A', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        NbTrial=sum(strcmp('AuditoryLocation', Stim_Time{1,1}));

        AudLocResp = nan(NbTrial,1);
        AudLocRT = nan(NbTrial,1);
        ComSrcResp = nan(NbTrial,1);
        ComSrcRT = nan(NbTrial,1);

        iTrial = 0;

        for i=1:length(Stim_Time{1,1})
            if strcmp('AuditoryLocation', Stim_Time{1,1}(i,:))
                iTrial = iTrial+1;
                ComSrc = 0;
                AudLoc = 1;
                TEMP1 = str2num(char(Stim_Time{1,2}(i,:)));
            elseif strcmp('CommonSource', Stim_Time{1,1}(i,:))
                ComSrc = 1;
                TEMP2 = str2num(char(Stim_Time{1,2}(i,:)));
            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) || strcmp('3', Stim_Time{1,1}(i,:)) || strcmp('4', Stim_Time{1,1}(i,:))
                if AudLoc
                    if strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:))
                        AudLoc=0;
                        AudLocResp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                        AudLocRT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP1)/10000;
                    end
                elseif ComSrc
                    if strcmp('3', Stim_Time{1,1}(i,:)) || strcmp('4', Stim_Time{1,1}(i,:))
                        AudLoc=0;
                        ComSrc=0;
                        ComSrcResp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                        ComSrcRT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP2)/10000;
                    end
                end
            end
        end

        AudLocResp(AudLocResp==1)=-1;
        AudLocResp(AudLocResp==2)=1;


        ComSrcResp(ComSrcResp==3)=1;
        ComSrcResp(ComSrcResp==4)=0;



        % Compiles data
        % Trial type // True Audio Loc // True Visual Loc // Resp Audio Loc // RT Resp Audio // Com Source // RT Com Source
        % Trial type : 3 --> CON ; 4 --> INC
        % True Audio Loc : -1 --> Left ; 1 --> Right
        % Resp Audio Loc : -1 --> Left ; 1 --> Right
        % Com Source : 1 --> Same ; 0 --> Different

        Data{iFile} = [TrialList(1:length(AudLocResp)) AudioSide(1:length(AudLocResp)) VisualSide(1:length(AudLocResp)) AudLocResp AudLocRT ComSrcResp ComSrcRT];



        Accuracy(iFile) = sum(any([all(Data{iFile}(:,[2 4])==repmat([-1 -1],size(Data{iFile},1),1),2) ...
            all(Data{iFile}(:,[2 4])==repmat([1 1],size(Data{iFile},1),1),2)], 2))/size(Data{iFile},1);

        AccuracyCon(iFile) = sum(any([all(Data{iFile}(:,[1 2 4])==repmat([3 -1 -1],size(Data{iFile},1),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([3 1 1],size(Data{iFile},1),1),2)], 2))/sum(Data{iFile}(:,1)==3);

        AccuracyInc(iFile) = sum(any([all(Data{iFile}(:,[1 2 4])==repmat([4 -1 -1],size(Data{iFile},1),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([4 1 1],size(Data{iFile},1),1),2)], 2))/sum(Data{iFile}(:,1)==4);

        PercComCon(iFile) = sum(all(Data{iFile}(:,[1 6])==repmat([3 1],size(Data{iFile},1),1),2))/sum(Data{iFile}(:,1)==3);

        PercComInc(iFile) = sum(all(Data{iFile}(:,[1 6])==repmat([4 1],size(Data{iFile},1),1),2))/sum(Data{iFile}(:,1)==4);


        CMB(iFile) = mean((Data{iFile}(Data{iFile}(:,1)==4,4) - Data{iFile}(Data{iFile}(:,1)==4,2))./ ...
            (Data{iFile}(Data{iFile}(:,1)==4,3) - Data{iFile}(Data{iFile}(:,1)==4,2)));

        IncSame = all(Data{iFile}(:,[1 6])==repmat([4 1],size(Data{iFile},1),1),2);
                 sum(IncSame)
        CMB_Same(iFile) = mean( ...
            (Data{iFile}(IncSame,4) - Data{iFile}(IncSame,2))./ ...
            (Data{iFile}(IncSame,3) - Data{iFile}(IncSame,2)) ...
            );

        IncDiff = all(Data{iFile}(:,[1 6])==repmat([4 0],size(Data{iFile},1),1),2);
                 sum(IncDiff)
        CMB_Diff(iFile) = mean( ...
            (Data{iFile}(IncDiff,4) - Data{iFile}(IncDiff,2))./ ...
            (Data{iFile}(IncDiff,3) - Data{iFile}(IncDiff,2)) ...
            );


    end

    %%
    figure('name', ['Subject ' num2str(Subjects(SubjInd))])
    hold on
    grid on
    plot(AccuracyCon, '-+b')
    plot(AccuracyInc, '-+r')
    plot(PercComCon, '-ob')
    plot(PercComInc, '-or')
    plot(CMB_Same, '-og')
    plot(CMB_Diff, '.-g')

    axis([0.5 2.5 -.1 1.1])

    AccuracyCon
    AccuracyInc
    PercComCon
    PercComInc
    CMB_Same
    CMB_Diff

    tmp = {'AccuracyCon';'AccuracyInc';'PercComCon';'PercComInc';'CMB Same';'CMB Diff'};

    set(gca, 'xtick', 1:2, 'xticklabel', ['1';'2'])
    xlabel('Run')

    clear Accuracy AccuracyCon AccuracyInc PercComCon PercComInc CMB CMB_Same CMB_Diff
    
    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd)))))
    print(gcf, 'Results.tif', '-dtiff')
    legend(char(tmp))  
    print(gcf, 'Results_Legend.tif', '-dtiff')
    

    cd(StartDirectory)

end

