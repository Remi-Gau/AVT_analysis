clear; clc;

% Runs
% A only : 1001 <= runs < 2001
% AV : 2001 <= runs < 3001
% A, V or T : 3001 <= runs < 4001
% T only : 4001 <= runs < 5001

% With feedback : runs = ?1??
% No feedback : runs = ?0??

%Trials
% A --> 1
% V --> 2
% AV --> 3 and 4
% T --> 5
% Baseline --> 0

Subj2Create = 0:3;

Param.RunsToCreate = 1;
Param.Side = [4 12 4 12 4 4 12 12];
Param.SOA = 2.1;
Param.Fixation = 0;
Param.FixDur = 10;

StartDirectory = pwd;

%% Saves the trial lists
for iSubj = Subj2Create

    for RunInd = Param.RunsToCreate

        TrialList = [];
        SideList = [];
        SOAList = [];

        %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
        for iRepeat = 1:numel(Param.Side)

            TMP1 = repmat([5;8],6,1);
            TMP1 = TMP1(randperm(numel(TMP1)));
            TrialList = [TrialList ; TMP1; Param.Fixation];
            SideList = [SideList ; Param.Side(iRepeat)*ones(12,1) ; Param.Fixation];
            SOAList = [SOAList ; Param.SOA*ones(12,1) ; Param.FixDur];

        end % iRepeat = 1:Repeats

        TrialListComp{1,RunInd}=[TrialList SideList SOAList];


        %% Print out proportion of targets per run and time per run
        Insert=' Touch only ';

        fprintf(['For ' Insert ' runs\n'])

        fprintf('fMRI runs last %0.2f min. \n', [10+sum(SOAList)]/60)

        tabulate(TrialList(TrialList>0)/2+SideList(TrialList>0)/3)


        %% Compute efficiency
        clear S SOT_List PresTime_List

        S.bf = 'hrf';
        S.HC = 128;
        S.TR = 3;
        S.t0 = 3;

        SOT_List=cumsum(SOAList);

        S.CM{1} = [1 0];
        S.CM{2} = [0 1];
        S.sots{1} = SOT_List(SideList==4)/S.TR;
        S.sots{2} = SOT_List(SideList==12)/S.TR;

        S.Ns = round(SOT_List(end)/S.TR)+10;

        if RunInd==1
            S.Ns
        end
        [e, X] = fMRI_GLM_efficiency(S);

        close all
        Colors = 'rgbcmk';
        figure('name', Insert, 'position', [100 100 1200 550])
        subplot(2,2,1)
        hold on
        for i=1:length(S.sots)
            stem(S.sots{i},ones(1,length(S.sots{i})), Colors(i))
        end
        axis([0 [10+sum(SOAList)]/S.TR 0 1.2])
        set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(S.sots{1}(end)+10) ,...
            'xticklabel', S.TR*(0:10:ceil(S.sots{1}(end)+10)), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',12);

        subplot(2,2,3)
        hold on
        for i=1:length(S.sots)
            plot(X(:,i), Colors(i))
        end
        axis([0 [10+sum(SOAList)]/S.TR min(X(:)) max(X(:))])
        set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(S.sots{1}(end)+10) ,...
            'xticklabel', S.TR*(0:10:ceil(S.sots{1}(end)+10)), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',12);

        subplot(2,2,[2 4])
        colormap(gray)
        imagesc(X)


        %%
        RunNumber = RunInd + 4000;

        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(StartDirectory, strcat('Subject_', num2str(iSubj))));

        TrialListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Trial_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid1 = fopen (TrialListFile, 'w');

        SideListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Side_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid2 = fopen (SideListFile, 'w');

        for TrialInd = 1:length(TrialList)
            fprintf (fid1, '%i\n', TrialList(TrialInd) );
            fprintf (fid2, '%i\n', SideList(TrialInd) );
        end

        fclose (fid1);
        fclose (fid2);

    end

end


TrialListComp
