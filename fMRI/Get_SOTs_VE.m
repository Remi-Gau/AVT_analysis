%%
clc; clear all; close all;

Subjects = [11];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'fMRI'))

    LogFileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_2*.txt'));
    TrialListFileList = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_2*.txt'));

    SOT=cell(3,2,length(LogFileList));

    for iFile = 1:length(LogFileList)

        % Loads trial type order presented
        TrialList = load(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        TrialList(TrialList==0) = [];

        disp(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt'])

        % Loads side order presented
        SideList = load(['Audio_Side_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        SideList(SideList==0) = [];

        disp(['Audio_Side_List_Subject_', num2str(Subjects(SubjInd)), ...
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
        TEMP = [TEMP ; find(strcmp('PositiveFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('NegativeFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('BREAK', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        iTrial = 1;

        for i=1:length(TrialList)
            
            Side = SideList(i)-1;
            
            if TrialList(i)>2
                TrialType=TrialList(i)-1;
            else
                TrialType=TrialList(i);
            end

            SOT{TrialType,Side,iFile}(end+1) = (str2double(Stim_Time{1,2}(iTrial,:)) - StartTime)/10000;
            iTrial = iTrial+1;

        end
        
        S.bf = 'hrf';
        S.HC = 128;
        S.TR = 3;
        S.t0 = 3;

        S.CM{1} = [1 0 0 0 0];
        S.CM{2} = [0 1 0 0 0];
        S.CM{3} = [0 0 1 0 0];
        S.CM{4} = [0 0 0 1 0];
        S.sots{1} = SOT{2,1,iFile}/S.TR;
        S.sots{2} = SOT{2,2,iFile}/S.TR;
        S.sots{3} = SOT{3,1,iFile}/S.TR;
        S.sots{4} = SOT{3,2,iFile}/S.TR;
        S.sots{5} = [SOT{1,1,iFile} SOT{1,2,iFile}]/S.TR;

        S.Ns = ceil((S.Ns/S.TR)+10);
        
        cd(StartDirectory)
        [e, X] = fMRI_GLM_efficiency(S);
        
        close all
        Colors = 'rgbcmk';
        figure('name', 'AV', 'position', [100 100 1200 550])
        subplot(2,2,1)
        hold on
        for i=1:length(S.sots)
            stem(S.sots{i},ones(1,length(S.sots{i})), Colors(i))
        end
        axis([0 10+S.Ns 0 1.2])
        set(gca,'tickdir', 'out', 'xtick', 0:5:(10+S.Ns) ,...
            'xticklabel', (0:5:(10+S.Ns))*S.TR, ...
            'ticklength', [0.01 0.01], 'fontsize', 10)
        t=xlabel('Time (s)');
        set(t,'fontsize',10);

        subplot(2,2,3)
        hold on
        for i=1:length(S.sots)
            plot(X(:,i), Colors(i))
        end
        axis([0 10+S.Ns min(X(:)) max(X(:))])
        set(gca,'tickdir', 'out', 'xtick', 0:5:(10+S.Ns) ,...
            'xticklabel', (0:5:(10+S.Ns))*S.TR, ...
            'ticklength', [0.01 0.01], 'fontsize', 10)
        t=xlabel('Time (s)');
        set(t,'fontsize',10);

        subplot(2,2,[2 4])
        colormap(gray)
        imagesc(X)

    end

end

