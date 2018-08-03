clear; clc; close all;

addpath(fullfile(pwd, 'subfun'));

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

Subj2Create = 0;
fMRI = 1;

Param.RunsToCreate = 1:2;

if fMRI 
    MiniBlocks = [4 3 2 1 4 3 2 1];
    
    Cdtion = [
        3 2 2;
        3 6 6;
        3 10 10;
        3 14 14;
        4 2 14;
        4 14 2;
        4 6 10;
        4 10 6;
        ];

    Param.FixDur = 7;
else
    MiniBlocks = [4 3 2 1]; %#ok<*UNRCH>
    
    Cdtion = [
        3 2 2;
        3 6 6;
        3 10 10;
        3 14 14;
        4 2 6;
        4 2 10;
        4 2 14;
        4 6 2;        
        4 6 10;
        4 6 14;
        4 10 2;
        4 10 6;
        4 10 14;
        4 14 2;
        4 14 6;
        4 14 10;        
        ];
    
    Param.FixDur = 7;
end

Param.Repeats = size(Cdtion,1);


Param.Cells2Shuffle = {};
for iMiniBlocks=1:length(MiniBlocks)
    for iCdtion = 1:size(Cdtion,1)
        Param.Cells2Shuffle{end+1,1} = ones(MiniBlocks(iMiniBlocks),1)*Cdtion(iCdtion,1);
        Param.Cells2Shuffle{end,2} = ones(MiniBlocks(iMiniBlocks),1)*Cdtion(iCdtion,2);
        Param.Cells2Shuffle{end,3} = ones(MiniBlocks(iMiniBlocks),1)*Cdtion(iCdtion,3);
    end
end
    
Param.Shuffle = reshape(1:size(Param.Cells2Shuffle,1),size(Cdtion,1),size(Param.Cells2Shuffle,1)/size(Cdtion,1))';

Param.SOA = 2.2;
Param.Fixation = 0;

COLOR =   [...
166,206,227;
31,120,180;
178,223,138;
51,160,44;
251,154,153;
227,26,28;
253,191,111;
255,127,0;
202,178,214;
106,61,154;
255,255,153;
177,89,40;
0,0,0;
128,128,128;
190,190,190;
60,60,60];
COLOR=COLOR/255;

StartDirectory = pwd;



SelectAll = [];
for i=1:length(MiniBlocks)
    SelectAll(end+1,:) = randperm(Param.Repeats); %#ok<*SAGROW>
end

%% Randomization is different across runs but same across subjects
for RunInd = Param.RunsToCreate

    if mod(RunInd,7)==0
        SelectAll = [];
    end
    
    if isempty(SelectAll)
        for i=1:length(MiniBlocks)
            SelectAll(end+1,:) = randperm(Param.Repeats); %#ok<*SAGROW>
        end
    end
    
    TrialList = [];
    A_SideList = [];
    V_SideList = [];
    SOAList = [];

    Select = [];

    %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
    for iRepeat = 1:Param.Repeats
        
        if isempty(Select)
            
            BadOrder=[1 1];
            
            while BadOrder
                
                Select = [];
                for i=1:length(MiniBlocks)
                    Select(end+1,:) = randperm(Param.Repeats);
                end
                
                for i=1:size(Select,2)
                    if numel(unique(Select(:,i)))<size(Select,1)
                         BadOrder(1)=1;
                        break;
                    else
                        BadOrder(1)=0;
                    end
                end
                
                tmp = SelectAll == repmat(Select,[1,1,size(SelectAll,3)]);
                if any(all(all(tmp)))
                    BadOrder(2)=1;
                else
                    BadOrder(2)=0;
                    SelectAll(:,:,end+1)= Select; 
                end
                
            end
        end

        NewOrder = [];

        tmp = Select(:,1);

        for i=1:numel(tmp)
            NewOrder = [NewOrder Param.Shuffle(i,tmp(i))];
        end

        while any(diff(tmp)==0)
            tmp2 = randperm(numel(tmp));
            tmp=tmp(tmp2);
            NewOrder = NewOrder(tmp2);
        end

        Select(:,1) = [];

        for i=1:numel(NewOrder)

            TrialList = [TrialList ; Param.Cells2Shuffle{NewOrder(i),1}]; %#ok<*AGROW>
            A_SideList = [A_SideList ; Param.Cells2Shuffle{NewOrder(i),2}];
            V_SideList = [V_SideList ; Param.Cells2Shuffle{NewOrder(i),3}];
            SOAList = [SOAList ; Param.SOA*ones(numel(Param.Cells2Shuffle{NewOrder(i),3}),1)];

            if any(TrialList==Param.Fixation)

                if sum(SOAList(find(TrialList==Param.Fixation, 1,'last')+1:end))>42
                    error('Block too long')
                elseif sum(SOAList(find(TrialList==Param.Fixation, 1,'last')+1:end))>34 ...
                        && sum(SOAList(find(TrialList==Param.Fixation, 1,'last')+1:end))<42
                    TrialList = [TrialList ; Param.Fixation];
                    A_SideList = [A_SideList ; Param.Fixation];
                    V_SideList = [V_SideList ; Param.Fixation];
                    SOAList = [SOAList ; Param.FixDur];
                end
            else
                if sum(SOAList)>42
                    error('Block too long')
                elseif sum(SOAList)>34 && sum(SOAList)<42
                    TrialList = [TrialList ; Param.Fixation];
                    A_SideList = [A_SideList ; Param.Fixation];
                    V_SideList = [V_SideList ; Param.Fixation];
                    SOAList = [SOAList ; Param.FixDur];
                end
            end

        end

    end % iRepeat = 1:Repeats
    
    TrialList = [TrialList ; Param.Fixation];
    A_SideList = [A_SideList ; Param.Fixation];
    V_SideList = [V_SideList ; Param.Fixation];
    SOAList = [SOAList ; Param.FixDur];

    TrialListComp{1,RunInd}=[TrialList A_SideList V_SideList SOAList];


    %% Print out proportion of targets per run and time per run
    Insert=' AV ';

    fprintf(['For ' Insert ' runs\n'])

    if fMRI
        fprintf('fMRI runs last %0.2f min. \n\n', [10+sum(SOAList)]/60)
    else
        fprintf('PsychoPhysics runs last %0.2f min. \n\n', [10+sum(SOAList)]/60)
    end
    
    for iCdtion = 1:size(Cdtion,1)
        TrialCount(iCdtion) = sum(all([TrialList==Cdtion(iCdtion,1) A_SideList==Cdtion(iCdtion,2)],2));
    end

    fprintf(repmat('%i ',[1 size(Cdtion,1)]), TrialCount);
    fprintf('\n\n');

    tabulate(V_SideList(TrialList>0)+(A_SideList(TrialList>0)/3))


    %% Compute efficiency
    if fMRI
        clear S SOT_List PresTime_List

        S.bf = 'hrf';
        S.HC = 128;
        S.TR = 3;
        S.t0 = 3;

        SOT_List=cumsum(SOAList);

        for iCdtion = 1:size(Cdtion,1)
            S.CM{iCdtion} = zeros(1,size(Cdtion,1));
            S.CM{iCdtion}(iCdtion) = 1;
            S.sots{iCdtion} = SOT_List(...
                all([V_SideList==Cdtion(iCdtion,2) A_SideList==Cdtion(iCdtion,3)],2)...
                )/S.TR; %ConL
        end

        S.Ns = round(SOT_List(end)/S.TR)+5;

        fprintf('\nNumber of volumes: %i\n\n', S.Ns)
        
        [e, X] = fMRI_GLM_efficiency(S);
        
        Eff(RunInd) = mean(e)

        figure('name', [Insert ' - Run: ' num2str(RunInd)], 'position', [100 100 1200 550])
        subplot(2,2,1)
        hold on
        for i=1:length(S.sots)
            stem(S.sots{i},ones(1,length(S.sots{i})), 'color', COLOR(i,:))
        end
        axis([0 [10+sum(SOAList)]/S.TR 0 1.2])
        set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(10+sum(SOAList)) ,...
            'xticklabel', S.TR*(0:10:ceil(10+sum(SOAList))), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',10);

        subplot(2,2,3)
        hold on
        for i=1:length(S.sots)
            plot(X(:,i), 'color', COLOR(i,:))
        end
        axis([0 [10+sum(SOAList)]/S.TR min(X(:)) max(X(:))])
        set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(10+sum(SOAList)) ,...
            'xticklabel', S.TR*(0:10:ceil(10+sum(SOAList))), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',12);

        subplot(2,2,[2 4])
        colormap(gray)
        imagesc(X)
        
    else
        S.TR = 3;
        
        SOT_List=cumsum(SOAList);
        
        for iCdtion = 1:size(Cdtion,1)
            S.sots{iCdtion} = SOT_List(...
                all([V_SideList==Cdtion(iCdtion,2) A_SideList==Cdtion(iCdtion,3)],2)...
                )/S.TR; %ConL
        end
        
        figure('name', [Insert ' - Run: ' num2str(RunInd)], 'position', [100 100 1200 550])
        hold on
        for i=1:length(S.sots)
            stem(S.sots{i},ones(1,length(S.sots{i})), 'color', COLOR(i,:))
        end
        axis([0 [10+sum(SOAList)]/S.TR 0 1.2])
        set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(10+sum(SOAList)) ,...
            'xticklabel', S.TR*(0:10:ceil(10+sum(SOAList))), ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        t=xlabel('Time (s)');
        set(t,'fontsize',10);
        
    end

    %% Saves the trial lists
    for iSubj = Subj2Create

        RunNumber = RunInd + 2000;
        if ~fMRI
            RunNumber=RunNumber+100;
        end

        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(StartDirectory, strcat('Subject_', num2str(iSubj))));

        TrialListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Trial_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid1 = fopen (TrialListFile, 'w');

        AudioSideListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Audio_Side_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid2 = fopen (AudioSideListFile, 'w');

        VisualSideListFile = fullfile(StartDirectory, strcat('Subject_', num2str(iSubj)), ...
            strcat('Visual_Side_List_Subject_', num2str(iSubj), '_Run_', num2str(RunNumber), '.txt'));
        fid3 = fopen (VisualSideListFile, 'w');

        for TrialInd = 1:length(TrialList)
            fprintf (fid1, '%i\n', TrialList(TrialInd) );
            fprintf (fid2, '%i\n', A_SideList(TrialInd) );
            fprintf (fid3, '%i\n', V_SideList(TrialInd) );
        end

        fclose (fid1);
        fclose (fid2);
        fclose (fid3);

    end % iSubj = Subj2Create

end % RunInd = RunsToCreate


TrialListComp
