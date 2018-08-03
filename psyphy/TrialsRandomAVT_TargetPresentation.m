clear; clc; close all

addpath(fullfile(pwd, 'subfun'))
addpath(genpath('C:\Users\Remi\Documents\MATLAB\spm8'))

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

Subj2Create = 17:19;

Trials = [...
    6 4;
    7 4;
    8 4;
    6 12;
    7 12;
    8 12;
    1 4;
    2 4;
    5 4;
    1 12;
    2 12;
    5 12;
    ];

SOA = 2.2;

StartDirectory = pwd;

for iSubj = Subj2Create
    
    for RunInd = 1
        
        TrialList = [];
        SideList = [];
        SOAList = [];
        
        %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
        for iRepeat = 1:2
            
            
            Mix = randperm(size(Trials,1));
            
            
            TrialList = [TrialList;Trials(Mix,1)];
            SideList = [SideList;Trials(Mix,2)];
            SOAList = [SOAList;SOA*ones(size(Trials,1),1)];
            
        end % iRepeat = 1:Repeats
        
        
        %% Print out proportion of targets per run and time per run
        
        fprintf('\n%i %i %i %i %i %i %i %i %i %i %i %i\n\n', ...
            sum(all([TrialList==1 SideList==4],2)), ...
            sum(all([TrialList==1 SideList==12],2)), ...
            sum(all([TrialList==2 SideList==4],2)), ...
            sum(all([TrialList==2 SideList==12],2)), ...
            sum(all([TrialList==5 SideList==4],2)), ...
            sum(all([TrialList==5 SideList==12],2)), ...
            sum(all([TrialList==6 SideList==4],2)), ...
            sum(all([TrialList==6 SideList==12],2)), ...
            sum(all([TrialList==7 SideList==4],2)), ...
            sum(all([TrialList==7 SideList==12],2)), ...
            sum(all([TrialList==8 SideList==4],2)), ...
            sum(all([TrialList==8 SideList==12],2)) ...
            );
        
        tabulate(TrialList(TrialList>0)*8+(SideList(TrialList>0))/3)
        
        %% Plot
        S.TR = 3;
        SOT_List=cumsum(SOAList);
        
        S.sots{1} = SOT_List(all([TrialList==1 SideList==4],2))/S.TR; %A_L
        S.sots{2} = SOT_List(all([TrialList==2 SideList==4],2))/S.TR; %V_L
        S.sots{3} = SOT_List(all([TrialList==5 SideList==4],2))/S.TR; %T_L
        S.sots{4} = SOT_List(all([TrialList==1 SideList==12],2))/S.TR; %A_R
        S.sots{5} = SOT_List(all([TrialList==2 SideList==12],2))/S.TR; %V_R
        S.sots{6} = SOT_List(all([TrialList==5 SideList==12],2))/S.TR; %T_R
        S.sots{7} = SOT_List(all([TrialList==6 SideList==4],2))/S.TR; %A_L
        S.sots{8} = SOT_List(all([TrialList==7 SideList==4],2))/S.TR; %V_L
        S.sots{9} = SOT_List(all([TrialList==8 SideList==4],2))/S.TR; %T_L
        S.sots{10} = SOT_List(all([TrialList==6 SideList==12],2))/S.TR; %A_R
        S.sots{11} = SOT_List(all([TrialList==7 SideList==12],2))/S.TR; %V_R
        S.sots{12} = SOT_List(all([TrialList==8 SideList==12],2))/S.TR; %T_R
        
        Colors = [...
            1 0 0;
            0 1 0;
            0 0 1;
            1 1 0;
            0 1 1;
            1 0 1;
            .5 0 0;
            0 .5 0;
            0 0 .5;
            .5 .5 0;
            0 .5 .5;
            .5 0 .5;
            ];
        
        figure('name', ['AVT - Target presentation run: ' num2str(RunInd)], 'position', [100 100 1200 550])
        hold on
        for i=1:length(S.sots)
            stem(S.sots{i},ones(1,length(S.sots{i})), 'color',Colors(i,:))
        end
        axis([0 [10+sum(SOAList)]/S.TR 0 1.2]) %#ok<NBRAK>
        set(gca,'tickdir', 'out', 'xtick', 0:5:ceil(10+sum(SOAList)) ,...
            'xticklabel', S.TR*(0:5:ceil(10+sum(SOAList))), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',8);
        
        %%
        RunNumber = RunInd + 3200;
        
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
        
    end % RunInd = RunsToCreate
    
end % iSubj = Subj2Create

