clear; clc; close all

% Runs
% A only : 1001 <= runs < 2001
% AV : 2001 <= runs < 3001
% A, V or T : 3001 <= runs < 4001
% T only : 4001 <= runs < 5001

% With feedback : runs = ?1??
% No feedback : runs = ?0??

%Trials
% A --> 1

% array <int> PresentationLocationsDeg[15]= {-12, -10, -8, -5, -4, -3, -1, 0, 1, 3, 4, 5, 8, 10, 12};
% 5 8 11

Subj2Create = 0;
Feedback = 0;

Param.RunsToCreate = 1;
Param.Repeats = 6;
Param.TrialType = repmat([1 1 1 1], 10, 1);
Param.Side = repmat([2 6 10 14], 10, 1);
Param.SOA = repmat(2.1,40,1);

if Feedback
    Param.Repeats = 6;
end

Colors = 'rgbcmyk';

AllOders = randperm(length(Param.TrialType(:)));

StartDirectory = pwd;

%% Saves the trial lists
for iSubj = Subj2Create

    %% Randomization is different across runs
    for RunInd = Param.RunsToCreate

        TrialType = Param.TrialType(:);
        Side = Param.Side(:);
        SOA = Param.SOA;

        TrialList = [];
        A_SideList = [];
        SOAList = [];

        %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
        for iRepeat = 1:Param.Repeats

            BadOrder=1;
            while BadOrder
                NewOrder = randperm(length(TrialType));

                tmp = AllOders == repmat(NewOrder,[size(AllOders,1), 1]);
                if any(all(tmp))
                    BadOrder=1;
                else
                    AllOders(end+1,:)= NewOrder;
                    BadOrder=0;
                end
            end

            TMP1 = TrialType(NewOrder);
            TMP2 = Side(NewOrder);
            TMP3 = SOA(NewOrder);

            TrialList = [TrialList ; TMP1];
            A_SideList = [A_SideList ; TMP2];
            SOAList = [SOAList ; TMP3];

        end % iRepeat = 1:Repeats

        TrialListComp{1,RunInd}=[TrialList A_SideList SOAList];

        
        Insert=' Audio only ';
        %% Print out proportion of targets per run and time per run
        if RunInd==1
            fprintf(['For ' Insert ' runs\n'])

            fprintf('PsychoPhysics runs last %0.2f min. \n', [10+sum(SOAList)]/60)

            TrialPerCond=sum(all([TrialList==1 A_SideList==2],2));
            fprintf('%i trials per condition. \n\n', TrialPerCond);
        end

        SOT_List=cumsum(SOAList);

        Sots{1} = SOT_List(all([TrialList==1 A_SideList==2],2))/3;
        Sots{2} = SOT_List(all([TrialList==1 A_SideList==6],2))/3;
        Sots{3} = SOT_List(all([TrialList==1 A_SideList==10],2))/3;
        Sots{3} = SOT_List(all([TrialList==1 A_SideList==14],2))/3;

        figure('name', Insert, 'position', [100 100 1200 550])
        hold on
        for i=1:length(Sots)
            stem(Sots{i},ones(1,length(Sots{i})), Colors(i))
        end
        axis([0 [10+sum(SOAList)]/3 0 1.2])
        set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(Sots{1}(end)+10) ,...
            'xticklabel', 3*(0:10:ceil(Sots{1}(end)+10)), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',12);

        %%
        RunNumber = RunInd + Feedback*100 + 1000;

        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(StartDirectory, strcat('Subject_', num2str(iSubj))));

        TrialListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Trial_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid1 = fopen (TrialListFile, 'w');

        SideListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Side_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid2 = fopen (SideListFile, 'w');

        for TrialInd = 1:length(TrialList)
            fprintf (fid1, '%i\n', TrialList(TrialInd) );
            fprintf (fid2, '%i\n', A_SideList(TrialInd) );
        end

        fclose (fid1);
        fclose (fid2);

    end

end
