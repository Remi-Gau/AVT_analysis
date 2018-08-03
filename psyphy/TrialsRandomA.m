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

Subj2Create = 17:19;
Feedback = 1;

Param.RunsToCreate = 1;
Param.Repeats = 5;
Param.TrialType = repmat([1 1], 10, 1);
Param.Side = repmat([4 12], 10, 1);
Param.SOA = repmat(2.1,20,1);

if Feedback
    Param.Repeats = 2;
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


        %%
        RunNumber = RunInd + Feedback*100 + 1000;

        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(iSubj))));

        TrialListFile = fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(iSubj)), ...
            strcat('Trial_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid1 = fopen (TrialListFile, 'w');

        SideListFile = fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(iSubj)), ...
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
