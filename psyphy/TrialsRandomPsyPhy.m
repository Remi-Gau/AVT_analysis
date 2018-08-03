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
% Baseline --> 0

PresentationLocationsDeg = [-12, -10, -8, -5, -4, -3, -1, 0, 1, 3, 4, 5, 8, 10, 12];
% 5 8 11


Subj2Create = 17:19;

Param.RunsToCreate = 1:3;
Param.Repeats = 13;
Param.Side = [1 3 4 6:10 12 13 15]';
Param.SOA = 2.1*ones(11,1);

StartDirectory = pwd;

AllOders = randperm(length(Param.Side));

%% Randomization is different across runs but same across subjects
for RunInd = Param.RunsToCreate

    Side = Param.Side;
    SOA = Param.SOA;

    SideList = [];
    SOAList = [];

    %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
    for iRepeat = 1:Param.Repeats
        
        BadOrder=1;
        while BadOrder
            NewOrder = randperm(length(Side));

            tmp = AllOders == repmat(NewOrder,[size(AllOders,1), 1]);
            if any(all(tmp))
                BadOrder=1;
            else
                AllOders(end+1,:)= NewOrder;
                BadOrder=0;
            end
        end

        TMP2 = Side(NewOrder);
        TMP3 = SOA(NewOrder);

        SideList = [SideList ; TMP2];
        SOAList = [SOAList ; TMP3];

    end % iRepeat = 1:Repeats

    TrialListComp{1,RunInd}=[SideList SOAList];


    %% Print out proportion of targets per run and time per run
    if RunInd==1

        Insert=' PsyPhy ';

        fprintf(['For ' Insert ' runs\n'])

        fprintf('PsychoPhysics runs last %0.2f min. \n', [sum(SOAList)]/60)

        TrialPerCond=sum(SideList==1);
        fprintf('%i trials per condition. \n\n', TrialPerCond);

    end

    %% Saves the trial lists
    for iSubj = Subj2Create

            RunNumber = RunInd + 5000;
            
            TrialList=ones(numel(SideList),1);

            [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(iSubj))));

            TrialListFile = fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(iSubj)), ...
                strcat('Trial_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
            fid1 = fopen (TrialListFile, 'w');

            SideListFile = fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(iSubj)), ...
                strcat('Side_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
            fid2 = fopen (SideListFile, 'w');

            for TrialInd = 1:length(TrialList)
                fprintf (fid1, '%i\n', TrialList(TrialInd) );
                fprintf (fid2, '%i\n', SideList(TrialInd) );
            end

            fclose (fid1);
            fclose (fid2);

    end % iSubj = Subj2Create

end % RunInd = RunsToCreate
