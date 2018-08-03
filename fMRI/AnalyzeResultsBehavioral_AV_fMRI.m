%%
clc; clear all; %close all;

Subjects = [10 11];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)
    
    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'fMRI'))
    
    DataComp = [];
    
    for iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_200*.txt')))
        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_200', num2str(iFile) ,'*.txt'));
        TrialList = load(TEMP.name);
        TrialList(TrialList==0)=[];
        
        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_200', num2str(iFile) ,'*.txt'));
        AudioSide = load(TEMP.name);
        AudioSide(AudioSide==2) = -1; AudioSide(AudioSide==3) = 1;
        AudioSide(AudioSide==0)=[];
        
        
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
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Inc_Trial_A', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Con_Trial_A', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_A', Stim_Time{1,1}))];
        
        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP
        
        NbTrial=sum(strcmp('AudioVisual_Con_Trial_V', Stim_Time{1,1}) + ...
            strcmp('AudioVisual_Inc_Trial_V', Stim_Time{1,1}) + ...
            strcmp('AudioOnly_Trial_V', Stim_Time{1,1}));
        
        NbResp = sum(strcmp('1', Stim_Time{1,1}) + strcmp('2', Stim_Time{1,1}));
        
        iTrial = 0;
        
        IsTrial = 0;
        
        for i=1:length(Stim_Time{1,1})
            
            if strcmp('AudioVisual_Con_Trial_V', Stim_Time{1,1}(i,:)) || ...
                    strcmp('AudioVisual_Inc_Trial_V', Stim_Time{1,1}(i,:)) || ...
                    strcmp('AudioOnly_Trial_V', Stim_Time{1,1}(i,:))
                iTrial = iTrial+1;
                IsTrial = 1;
                TEMP = str2num(char(Stim_Time{1,2}(i,:)));
                
            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:))
                if IsTrial
                    IsTrial = 0;
                    Resp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                    RT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP)/10000;
                end
            end
        end
        
        Resp(Resp==1)=-1;
        Resp(Resp==2)=1;
        
        % Compiles data
        % Trial type // True Audio Loc // True Visual Loc // Resp Audio Loc // RT Resp Audio // Com Source // RT Com Source
        % Trial type : 3 --> CON ; 4 --> INC
        % True Audio Loc : -1 --> Left ; 1 --> Right
        % Resp Audio Loc : -1 --> Left ; 1 --> Right
        % Com Source : 1 --> Same ; 0 --> Different
        
        Data{iFile} = [TrialList(1:length(Resp)) AudioSide(1:length(Resp)) VisualSide(1:length(Resp)) Resp' RT'];
        
        DataComp = [DataComp;Data{iFile}];
        
        AccuracyCon(iFile) = sum(any([all(Data{iFile}(:,[1 2 4])==repmat([3 -1 -1],size(Data{iFile},1),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([3 1 1],size(Data{iFile},1),1),2)], 2))/sum(Data{iFile}(:,1)==3);
        
        AccuracyInc(iFile) = sum(any([all(Data{iFile}(:,[1 2 4])==repmat([4 -1 -1],size(Data{iFile},1),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([4 1 1],size(Data{iFile},1),1),2)], 2))/sum(Data{iFile}(:,1)==4);
        
        AccuracyA(iFile) = sum(any([all(Data{iFile}(:,[1 2 4])==repmat([1 -1 -1],size(Data{iFile},1),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([1 1 1],size(Data{iFile},1),1),2)], 2))/sum(Data{iFile}(:,1)==1);
        
        CMB(iFile) = mean((Data{iFile}(Data{iFile}(:,1)==4,4) - Data{iFile}(Data{iFile}(:,1)==4,2))./ ...
            (Data{iFile}(Data{iFile}(:,1)==4,3) - Data{iFile}(Data{iFile}(:,1)==4,2)));
        
        
        
    end % iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_200*.txt')))
    
    %%
    MeanAccuracyCon = mean( ...
        any([all(DataComp(DataComp(:,1)==3,[2 4])==repmat([-1 -1],sum(DataComp(:,1)==3),1),2) ...
        all(DataComp(DataComp(:,1)==3,[2 4])==repmat([1 1],sum(DataComp(:,1)==3),1),2)], 2)...
        );
    SEMAccuracyCon = std( ...
        any([all(DataComp(DataComp(:,1)==3,[2 4])==repmat([-1 -1],sum(DataComp(:,1)==3),1),2) ...
        all(DataComp(DataComp(:,1)==3,[2 4])==repmat([1 1],sum(DataComp(:,1)==3),1),2)], 2)...
        )/sum(DataComp(:,1)==3)^.5;
    
    MeanAccuracyInc = mean( ...
        any([all(DataComp(DataComp(:,1)==4,[2 4])==repmat([-1 -1],sum(DataComp(:,1)==4),1),2) ...
        all(DataComp(DataComp(:,1)==4,[2 4])==repmat([1 1],sum(DataComp(:,1)==4),1),2)], 2)...
        );
    SEMAccuracyInc = std( ...
        any([all(DataComp(DataComp(:,1)==4,[2 4])==repmat([-1 -1],sum(DataComp(:,1)==4),1),2) ...
        all(DataComp(DataComp(:,1)==4,[2 4])==repmat([1 1],sum(DataComp(:,1)==4),1),2)], 2)...
        )/sum(DataComp(:,1)==4)^.5;
    
    MeanAccuracyA = mean( ...
        any([all(DataComp(DataComp(:,1)==1,[2 4])==repmat([-1 -1],sum(DataComp(:,1)==1),1),2) ...
        all(DataComp(DataComp(:,1)==1,[2 4])==repmat([1 1],sum(DataComp(:,1)==1),1),2)], 2)...
        );
    SEMAccuracyA = std( ...
        any([all(DataComp(DataComp(:,1)==1,[2 4])==repmat([-1 -1],sum(DataComp(:,1)==1),1),2) ...
        all(DataComp(DataComp(:,1)==1,[2 4])==repmat([1 1],sum(DataComp(:,1)==1),1),2)], 2)...
        )/sum(DataComp(:,1)==1)^.5 ;
    
    MeanCMB = mean((DataComp(DataComp(:,1)==4,4) - DataComp(DataComp(:,1)==4,2))./ ...
        (DataComp(DataComp(:,1)==4,3) - DataComp(DataComp(:,1)==4,2)));
    SEM_CMB =  std((DataComp(DataComp(:,1)==4,4) - DataComp(DataComp(:,1)==4,2))./ ...
        (DataComp(DataComp(:,1)==4,3) - DataComp(DataComp(:,1)==4,2)))/sum(DataComp(:,1)==3+DataComp(:,4))^.5;
    
    %%
    figure('name', ['Subject ' num2str(Subjects(SubjInd))])
    hold on
    grid on
    plot(AccuracyCon, '-+b')
    plot(AccuracyInc, '-+r')
    plot(AccuracyA, '-+k')
    plot(CMB, '-og')
    errorbar(0, MeanAccuracyCon, SEMAccuracyCon, '-+b')
    errorbar(0, MeanAccuracyInc, SEMAccuracyInc, '-+r')
    errorbar(0, MeanAccuracyA, SEMAccuracyA, '-+k')
    errorbar(0, MeanCMB, SEM_CMB, '-og')
    
    axis([-0.5 length(AccuracyInc)+.5 -.1 1.1])
    
    tmp = {'AccuracyCon';'AccuracyInc';'AccuracyA';'CMB'};
    
    
    %set(gca, 'xtick', 1:2, 'xticklabel', ['1';'2'])
    xlabel('Run')
    
    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd)))))
    print(gcf, 'Results_fMRI.tif', '-dtiff')
    legend(char(tmp))  
    print(gcf, 'Results_fMRI_Legend.tif', '-dtiff')
    
    
    cd(StartDirectory)
    
end % SubjInd = 1:length(Subjects)

