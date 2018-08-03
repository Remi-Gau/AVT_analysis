%%
clc; clear all; close all;

Subjects = 7;

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd))), 'Behavioral'))

    LogFileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_30*.txt'));
    TrialListFileList = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_30*.txt'));

    SOT=cell(4,2,length(LogFileList));
    
    AllSOTs = cell(length(LogFileList),1);

    for iFile = 1:length(LogFileList)
        
        cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd))), 'Behavioral'))

        % Loads trial type order presented
        TrialList = load(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        TrialList(TrialList==0) = [];

        disp(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt'])

        % Loads side order presented
        SideList = load(['Side_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        SideList(SideList==0) = [];

        disp(['Side_List_Subject_', num2str(Subjects(SubjInd)), ...
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

        StartTime =  str2num(Stim_Time{1,2}(find(strcmp('Start', Stim_Time{1,1})),:));

        Duration =  (str2num(Stim_Time{1,2}(end,:)) - StartTime)/600000
        
        S.Ns = Duration*60;

        TEMP = find(strcmp('30', Stim_Time{1,1}));
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Target_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Con_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Inc_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('2', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('1', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        iTrial = 1;

        for i=1:length(TrialList)
            
            if SideList(i)<8
                Side = 1;
            else
                Side = 2;
            end
            
            if TrialList(i)>5
                TrialType = 4;
            elseif TrialList(i)>4
                TrialType=TrialList(i)-2;
            else
                TrialType=TrialList(i);
            end
            
            if (str2double(Stim_Time{1,2}(iTrial,:)) - StartTime)/10000<0
                error('negative SOT')
            end

            AllSOTs{iFile,1}(end+1) = (str2double(Stim_Time{1,2}(iTrial,:)) - StartTime)/10000;
            
            iTrial = iTrial+1;

        end
 
        tmp = diff(AllSOTs{iFile,1});
        A = [[tmp';0] TrialList];
        tmp(tmp>6) = [];      
        fprintf('%f +/- %f secs\n\n\n\n', mean(tmp), std(tmp))
        
        A(A(:,1)>6,:) = [];
        for i=[1 2 5 6 7 8]
        disp(i)
        fprintf('%f +/- %f secs\n\n', mean(A(A(:,2)==i,1)), std(A(A(:,2)==i,1)))
        end
        

        
    end

end

