% Runs
% A only : 1001 <= runs < 2001
% AV : 2001 <= runs < 3001
% A, V or T : 3001 <= runs < 4001
% T only : 4001 <= runs < 5001

% With feedback : runs = ?1??
% No feedback : runs = ?0??

clear; clc;

StartDirectory = pwd;

Subj2Create = 14;

RunType = 3:4


for iRunType = RunType

    clear Param Cells2Shuffle

    %% Set parameters
    switch iRunType
        case 1 % A only
            Param.Feedback = 0:1;
            Param.RunsToCreate = 1:2;
            Param.Repeats = 1; %PsyPhy = 1 %fMRI = 8
            Param.TrialPerCond = 50; %PsyPhy = 50 %fMRI = 6
            Param.TrialType = [ones(Param.TrialPerCond,1);ones(Param.TrialPerCond,1)];
            Param.Side = [ones(Param.TrialPerCond,1)*2 ; ones(Param.TrialPerCond,1)*3];
            Param.TrialDuration = 50;
            Param.FixDur = 10;
            Param.SOA = 2.750;

        case 2 % AV
            Param.Feedback = 0;
            Param.RunsToCreate = 1:4;
            Param.Repeats = 1; %PsyPhy = 1 %fMRI = 7
            Param.TrialPerCond = 50; %PsyPhy = 50 %fMRI = 4
            Param.TrialType = repmat([3;4],Param.TrialPerCond,1) ;
            Param.Side = [ones(Param.TrialPerCond,1)*2 ; ones(Param.TrialPerCond,1)*3];
            Param.TrialDuration = 50;
            Param.FixDur = 6;
            Param.SOA = 2.750;
%             Param.Cells2Shuffle = {...
%                 [3;3] [2;2];
%                 [4;4] [2;2];
%                 [3;3] [3;3];
%                 [4;4] [3;3];
%                 [1] [2];
%                 [1] [3]};

        case 3 % A || V || T only
            Param.Feedback = 0:1;
            Param.RunsToCreate = 1:20;
            Param.Targets = 1*ones(2,3);
            Param.Repeats = 6;
            Param.TrialPerCond = 4;
            Param.TrialType = repmat([1;2;5],Param.TrialPerCond,1);
            Param.Side = [ones(6,1) ; ones(6,1)*4];
            Param.TrialDuration = 200;
            Param.FixDur = 6;
            Param.SOA = 2.750;
            Param.Cells2Shuffle = {...
                [1;1] [1;1];
                [2;2] [1;1];
                [5;5] [1;1];
                [1;1] [4;4];
                [2;2] [4;4];
                [5;5] [4;4]};

        case 4 % T Only
            Param.Feedback = 0;
            Param.RunsToCreate = 1:2;
            Param.TrialPerCond = 6 ;
            Param.Repeats = Param.TrialPerCond*2;
            Param.Targets = [zeros(2) Param.TrialPerCond*ones(2,1)];
            Param.TrialType = ones(6,1)*5;
            Param.Side = [ones(3,1) ; ones(3,1)*4];
            Param.TrialDuration = 200;
            Param.FixDur = 6;
            Param.SOA = 2.750;
    end

    TrialPerCond = Param.TrialPerCond;

    %% Different if FB present or not
    for iFB = Param.Feedback

        clear TrialListComp NewOrderList

        if iFB==1;
            RunsToCreate=1:2;
        else
            RunsToCreate = Param.RunsToCreate;
        end

        %% Randomization is different across runs but same across subjects
        for RunInd = RunsToCreate

            clear Targets

            if iFB==1
                switch iRunType
                    case 1 % A only
                        Repeats = 1;
                        Param.TrialPerCond = 20;
                        Param.TrialType = [ones(Param.TrialPerCond,1);ones(Param.TrialPerCond,1)];
                        Param.Side = [ones(Param.TrialPerCond,1)*2 ; ones(Param.TrialPerCond,1)*3];
                    case 3 % A || V || T only
                        Targets = 3*ones(2,3);
                        Repeats = sum(Targets)/2;
                end
            else
                Repeats = Param.Repeats;
                if isfield(Param,'Targets')
                    Targets = Param.Targets;
                end
                if isfield(Param,'Cells2Shuffle')
                    Cells2Shuffle = Param.Cells2Shuffle;
                end
            end

            TrialType = Param.TrialType;
            Side = Param.Side;

            TrialList = [];
            SideList = [];

            %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
            for iRepeat = 1:Repeats

                clear NewOrder 

                if exist('Cells2Shuffle', 'var')
                    NewOrder = randperm(size(Cells2Shuffle,1));
                else
                    NewOrder = randperm(length(TrialType));
                end

                if iFB==0
                    if iRepeat==1 && RunInd==1
                        NewOrderList = NewOrder;
                    else
                        while any(all(repmat(NewOrder, size(NewOrderList,1),1)==NewOrderList,2))
                            if exist('Cells2Shuffle', 'var')
                                NewOrder = randperm(size(Cells2Shuffle,1));
                            else
                                NewOrder = randperm(length(TrialType));
                            end
                        end
                        NewOrderList(end+1,:) = NewOrder;
                    end
                end

                if exist('Cells2Shuffle', 'var')
                    TMP1 =[];
                    TMP2 =[];
                    for i=1:numel(NewOrder)
                        TMP1 = [TMP1 ; Cells2Shuffle{NewOrder(i),1}];
                        TMP2 = [TMP2 ; Cells2Shuffle{NewOrder(i),2}];
                    end
                else
                    TMP1 = TrialType(NewOrder);
                    TMP2 = Side(NewOrder);
                end


                %% Add targets if needed
                if exist('Targets', 'var')

                    if iRunType==3 && iFB == 0% more FB runs or when tactile only
                        AddTargets = 1;
                    elseif iRunType==4 % when tactile only
                        AddTargets = 1;
                    elseif iFB == 0
                        AddTargets = 1;
                    elseif iFB == 1 % more FB runs
                        AddTargets = 1:3;
                    end

                    for iTarget = AddTargets

                        i=randi(size(Targets,2),1);
                        j=randi(size(Targets,1),1);
                        while Targets(j,i)==0
                            i=randi(size(Targets,2),1);
                            j=randi(size(Targets,1),1);
                        end

                        Targets(j,i)=Targets(j,i)-1;

                        if i==3; i=5; end
                        if j==2; j=4; end

                        TMP3 = find(all([TMP1==i TMP2==j],2));
                        TMP1(TMP3(randi(length(TMP3),1))) = TMP1(TMP3(randi(length(TMP3),1)))+5;

                    end

                    TMP1(TMP1==10) = 8;

                end

                TrialList = [TrialList ; TMP1; 0];
                SideList = [SideList ; TMP2; 0];

            end % iRepeat = 1:Repeats

            TrialListComp{1,RunInd}=[TrialList SideList];

            %% Print out proportion of targets per run and time per run
            if RunInd==1

                switch iRunType
                    case 1
                        Insert=' Audio only ';
                    case 2
                        Insert='AV ';
                    case 3
                        Insert=' A/V/T ';
                    case 4
                        Insert=' Tactile only ';
                end

                fprintf(['For ' Insert ' runs\n'])

                if iFB==1
                    fprintf('With feedback\n')
                    fprintf('Proportion of targets is %0.2f percent. \n', sum(TrialList>5)/sum(TrialList~=0)*100)
                else
                    fprintf('Proportion of targets is %0.2f percent. \n', sum(TrialList>5)/sum(TrialList~=0)*100)
                    fprintf('fMRI runs last %0.2f min. \n', (sum(TrialList==0)*Param.FixDur + sum(TrialList~=0)*Param.SOA +30)/60)
                end

                fprintf('PsychoPhysics runs last %0.2f min. \n', (sum(TrialList==0)*0 + sum(TrialList~=0)*Param.SOA)/60)

                switch iRunType
                    case 1
                        TrialPerCond=sum(all([TrialList==1 SideList==2],2));
                    case 2
                        TrialPerCond=sum(all([TrialList==3 SideList==2],2));
                    case 3
                        TrialPerCond=sum(all([TrialList==1 SideList==1],2));
                    case 4
                        TrialPerCond=sum(all([TrialList==5 SideList==1],2));
                end
                fprintf('%i trials per condition. \n\n', TrialPerCond);

            end

            %% Compute efficiency
            if iFB==0
                clear S SOT_List PresTime_List

                S.bf = 'hrf';
                S.HC = 128;
                S.TR = 3;
                S.t0 = 3;

                PresTime_List = zeros(size(TrialList));
                PresTime_List(TrialList~=0)=Param.SOA;
                PresTime_List(TrialList==0)=Param.FixDur;

                SOT_List=cumsum(PresTime_List);

                if iRunType==1
                    S.CM{1} = [1 0];
                    S.CM{2} = [0 1];
                    S.sots{1} = SOT_List(all([TrialList==1 SideList==2],2))/S.TR;
                    S.sots{2} = SOT_List(all([TrialList==1 SideList==3],2))/S.TR;
                elseif iRunType==2                    
                    S.CM{1} = [1 0 0 0];
                    S.CM{2} = [0 1 0 0];
                    S.CM{3} = [0 0 1 0];
                    S.CM{4} = [0 0 0 1];
                    S.sots{1} = SOT_List(all([TrialList==3 SideList==2],2))/S.TR;
                    S.sots{2} = SOT_List(all([TrialList==3 SideList==3],2))/S.TR; 
                    S.sots{3} = SOT_List(all([TrialList==4 SideList==2],2))/S.TR;
                    S.sots{4} = SOT_List(all([TrialList==4 SideList==3],2))/S.TR;      
                elseif iRunType==3
                    S.CM{1} = [1 0 0 0 0 0];
                    S.CM{2} = [0 1 0 0 0 0];
                    S.CM{3} = [0 0 1 0 0 0];
                    S.CM{4} = [0 0 0 1 0 0];
                    S.CM{5} = [0 0 0 0 1 0];
                    S.CM{6} = [0 0 0 0 0 1];                    
                    S.sots{1} = SOT_List(all([TrialList==1 SideList==1],2))/S.TR;
                    S.sots{2} = SOT_List(all([TrialList==2 SideList==1],2))/S.TR;
                    S.sots{3} = SOT_List(all([TrialList==5 SideList==1],2))/S.TR;
                    S.sots{4} = SOT_List(all([TrialList==1 SideList==4],2))/S.TR;  
                    S.sots{5} = SOT_List(all([TrialList==2 SideList==4],2))/S.TR;
                    S.sots{6} = SOT_List(all([TrialList==5 SideList==4],2))/S.TR;                     
                elseif iRunType==4
                    S.CM{1} = [1 0];
                    S.CM{2} = [0 1];
                    S.sots{1} = SOT_List(all([TrialList==5 SideList==1],2))/S.TR;
                    S.sots{2} = SOT_List(all([TrialList==5 SideList==4],2))/S.TR;
                end

%                 SOT(:,RunInd)=S.sots{1};

                S.Ns = round(SOT_List(end)/S.TR)+10;

                if RunInd==1
                    S.Ns
                end
                fMRI_GLM_efficiency(S);
            end

            %% Saves the trial lists
            for iSubj = Subj2Create

                RunNumber = RunInd + 100*iFB + 1000*iRunType;

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

            end % iSubj = Subj2Create

        end % RunInd = RunsToCreate

        TrialListComp

    end % iFB = Param.Feedback

end % iRunType = RunType