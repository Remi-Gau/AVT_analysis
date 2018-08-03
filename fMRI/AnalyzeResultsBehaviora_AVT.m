%%
clc; clear all; close all;

Subjects = [1 2 5];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)
    
    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd)))))
    
    LogFileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_3*.txt'));
    TrialListFileList = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_3*.txt'));

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
        TEMP = [TEMP ; find(strcmp('PostStim_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_V', Stim_Time{1,1}))];
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
        NbResp=sum(strcmp('1', Stim_Time{1,1}));
        
        Hits = zeros(1,3);
        FalseAlarms = zeros(1,3);
        
        iTrial = 1;
        
        for i=1:length(Stim_Time{1,1})-1
            
            if TrialList(iTrial)>5
                IsTarget = 1;
                if TrialList(iTrial)==6
                    j=1;
                elseif TrialList(iTrial)==7
                    j=2;
                elseif TrialList(iTrial)==8
                    j=3;
                end
            else
                IsTarget = 0;
            end
            
            if strcmp('1', Stim_Time{1,1}(i+1,:))
                if IsTarget
                    Hits(j)=Hits(j)+1;
                else
                    FalseAlarms(j)=FalseAlarms(j)+1;
                end
            else
                iTrial=iTrial+1;
            end
            
        end
        
        Hits
        Miss = [NbATarget NbVTarget NbTTarget] - Hits
        FalseAlarms
        CorrectRejection =  [NbATrial NbVTrial NbTTrial] - FalseAlarms
        
        NbResp==sum(FalseAlarms)+sum(Hits)
        
    end
    
end

