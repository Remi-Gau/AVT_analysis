%%
clc; clear all; close all;

Subjects = [1 2 3];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    clear Stim_Time

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'fMRI'))

    for iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_400*.txt')))
        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_400', num2str(iFile) ,'*.txt'));
        TrialList = load(TEMP.name);

        TrialList(TrialList==0) = [];

        % Loads log file
        LogFile = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_400', num2str(iFile) ,'*.txt'));

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
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        Resp = zeros(numel(TrialList),1);

        NbTrials = sum([...
            strcmp('Tactile_Target', Stim_Time{1,1})+...
            strcmp('Tactile_Trial', Stim_Time{1,1})]);

        if numel(TrialList)~=NbTrials
            error('We seem to be missing some trials')
        end

        iTrial = 0;
        IsResp = 0;
        IsTrial = 0;

        ExtraResp = 0;

        for i=1:length(Stim_Time{1,1})
            if strcmp('Tactile_Target', Stim_Time{1,1}(i,:)) || strcmp('Tactile_Trial', Stim_Time{1,1}(i,:))
                IsTrial = 1;
                IsResp = 0;
                iTrial = iTrial+1;
            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) ...
                    || strcmp('3', Stim_Time{1,1}(i,:)) || strcmp('4', Stim_Time{1,1}(i,:))
                if IsTrial
                    Resp(iTrial) = 1;
                else
                    ExtraResp = ExtraResp+1;
                end
                IsTrial = 0;
                IsResp = 1;
            end
        end

        NbResp = sum([...
            strcmp('1', Stim_Time{1,1})+...
            strcmp('2', Stim_Time{1,1})+...
            strcmp('3', Stim_Time{1,1})+...
            strcmp('4', Stim_Time{1,1})]);

        if NbResp~=ExtraResp+sum(Resp)
            error('We seem to be missing some responses')
        end

        Hits = sum(all([Resp==1,TrialList==8],2))
        Miss = sum(TrialList==8)-Hits
        FalseAlarms = sum(all([Resp==1,TrialList==5],2))
        CorrectRejection = sum(TrialList==5)-FalseAlarms

        Accuracy = round([Hits/(Hits+Miss)]*100)

        FalseAlarmRate = FalseAlarms/(FalseAlarms+CorrectRejection);
        HitRate = Hits/(Hits+Miss);

        if FalseAlarmRate==1
            FalseAlarmRate = 1 - 1/(2*(CorrectRejection+FalseAlarms));
        elseif FalseAlarmRate==0
            FalseAlarmRate = 1/(2*(CorrectRejection+FalseAlarms));
        end

        if HitRate==1
            HitRate = 1 - 1/(2*((Hits+Miss)));
        elseif HitRate==0
            HitRate = 1/(2*((Hits+Miss)));
        end

        D_prime = norminv(HitRate)-norminv(FalseAlarmRate)

    end

    cd(StartDirectory)

end