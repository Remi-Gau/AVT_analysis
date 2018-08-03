clear; clc; close all

addpath(fullfile(pwd, 'subfun'))
addpath(genpath('C:\Users\Remi\Documents\MATLAB\spm8'))

% Runs
% A only : 1001 <= runs < 2001
% A, V or T : 3001 <= runs < 4001
% T only : 4001 <= runs < 5001

% With feedback : runs = ?1??
% No feedback : runs = ?0??

%Trials
% A --> 1
% V --> 2
% T --> 5
% Baseline --> 0

Subj2Create = 666;
fMRI = 1;


Param.RunsToCreate = 1;

Param.Repeats = 6;

Param.Cells2Shuffle = {...
    ones(4,1) 4*ones(4,1);
    2*ones(4,1) 4*ones(4,1);
    5*ones(4,1) 4*ones(4,1);
    ones(4,1) 12*ones(4,1);
    2*ones(4,1) 12*ones(4,1);
    5*ones(4,1) 12*ones(4,1);
    
    ones(4,1) 4*ones(4,1);
    2*ones(4,1) 4*ones(4,1);
    5*ones(4,1) 4*ones(4,1);
    ones(4,1) 12*ones(4,1);
    2*ones(4,1) 12*ones(4,1);
    5*ones(4,1) 12*ones(4,1);
    
    ones(3,1) 4*ones(3,1);
    2*ones(3,1) 4*ones(3,1);
    5*ones(3,1) 4*ones(3,1);
    ones(3,1) 12*ones(3,1);
    2*ones(3,1) 12*ones(3,1);
    5*ones(3,1) 12*ones(3,1);
    
    ones(3,1) 4*ones(3,1);
    2*ones(3,1) 4*ones(3,1);
    5*ones(3,1) 4*ones(3,1);
    ones(3,1) 12*ones(3,1);
    2*ones(3,1) 12*ones(3,1);
    5*ones(3,1) 12*ones(3,1);
    
    ones(2,1) 4*ones(2,1);
    2*ones(2,1) 4*ones(2,1);
    5*ones(2,1) 4*ones(2,1);
    ones(2,1) 12*ones(2,1);
    2*ones(2,1) 12*ones(2,1);
    5*ones(2,1) 12*ones(2,1);
    
    ones(2,1) 4*ones(2,1);
    2*ones(2,1) 4*ones(2,1);
    5*ones(2,1) 4*ones(2,1);
    ones(2,1) 12*ones(2,1);
    2*ones(2,1) 12*ones(2,1);
    5*ones(2,1) 12*ones(2,1);
    
    1 4;
    2 4;
    5 4;
    1 12;
    2 12;
    5 12;
    
    1 4;
    2 4;
    5 4;
    1 12;
    2 12;
    5 12;
    };

Param.Shuffle = reshape(1:size(Param.Cells2Shuffle,1),6,size(Param.Cells2Shuffle,1)/6)';

Param.SOA = 2.2;
Param.Fixation = 0;
Param.FixDur = 7;

Param.Targets = 5*ones(3,2);

StartDirectory = pwd;

for iSubj = Subj2Create
    
    SelectAll = [...
        randperm(6);...
        randperm(6);...
        randperm(6);...
        randperm(6);...
        randperm(6);...
        randperm(6);...
        randperm(6);...
        randperm(6)];
    
    for RunInd = Param.RunsToCreate
        
        %         close all
        
        TrialList = [];
        SideList = [];
        SOAList = [];
        Select = [];
        
        Targets = Param.Targets;
        
        PresentTarget = [zeros(1,size(Param.Cells2Shuffle,1)-sum(Targets(:))) ones(1,sum(Targets(:)))];
        PresentTarget = PresentTarget(randperm(numel(PresentTarget)));
        MiniBlockCounter = 0;
        
        %% We repeat the same sequence of trials and randomize it and insert a fixation in between each
        for iRepeat = 1:Param.Repeats
            
            if isempty(Select)
                
                BadOrder=[1 1];
                
                while any(BadOrder)
                    
                    Select = [...
                        randperm(6);...
                        randperm(6);...
                        randperm(6);...
                        randperm(6);...
                        randperm(6);...
                        randperm(6);...
                        randperm(6);...
                        randperm(6)];
                    
                    for i=1:size(Select,2)
                        if numel(unique(Select(:,i)))<size(Select,1)-3
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
                NewOrder = [NewOrder Param.Shuffle(i,tmp(i))]; %#ok<AGROW>
            end
            
            while any(diff(tmp)==0)
                tmp2 = randperm(numel(tmp));
                tmp=tmp(tmp2);
                NewOrder = NewOrder(tmp2);
            end
            
            for i=1:numel(NewOrder)
                
                TrialList = [TrialList; Param.Cells2Shuffle{NewOrder(i),1}];
                SideList = [SideList; Param.Cells2Shuffle{NewOrder(i),2}];
                SOAList = [SOAList; Param.SOA*ones(numel(Param.Cells2Shuffle{NewOrder(i),1}),1)];
                
                MiniBlockCounter = MiniBlockCounter + 1;
                
                %     6 4;
                %     7 4;
                %     8 4;
                %     6 12;
                %     7 12;
                %     8 12;
                
                if any(Targets(:))
                    %                     if rand>.365
                    if PresentTarget(MiniBlockCounter)
                        
                        x= ceil(rand*size(Targets,1));
                        y= ceil(rand*size(Targets,2));
                        while Targets(x,y)==0
                        x= ceil(rand*size(Targets,1));
                        y= ceil(rand*size(Targets,2));
                        end
                        
                        Targets(x,y)=Targets(x,y)-1;
                        
                        if x==1;
                            x=6;
                        elseif x==2;
                            x=7;
                        else
                            x=8;
                        end
                        
                        if y==1;
                            y=4;
                        else
                            y=12;
                        end
                        
                        TrialList = [TrialList; x];
                        SideList = [SideList; y];
                        SOAList = [SOAList; Param.SOA];
                        
                    end
                end
                
                LastFix = find(TrialList==Param.Fixation, 1, 'last');
                if isempty(LastFix)
                    LastFix=1;
                end
                
                if sum(SOAList(LastFix:end))>42
                    error('Block too long')
                    
                elseif sum(SOAList(LastFix:end))>30 && sum(SOAList(LastFix:end))<42
                    TrialList = [TrialList; Param.Fixation];
                    SideList = [SideList; Param.Fixation];
                    SOAList = [SOAList; Param.FixDur];
                end
                
            end
            
            Select(:,1) = [];
            
        end % iRepeat = 1:Repeats
        
        TrialList = [TrialList ; Param.Fixation];
        SideList = [SideList ; Param.Fixation];
        SOAList = [SOAList ; Param.FixDur];
        
        TrialListComp{1,RunInd}=[TrialList SideList SOAList]; %#ok<AGROW>
        
        
        %% Print out proportion of targets per run and time per run
        Insert=' AV ';
        
        fprintf(['For ' Insert ' runs\n'])
        
        if fMRI
            fprintf('fMRI runs last %0.2f min. \n\n', [10+sum(SOAList)]/60) %#ok<NBRAK>
        else
            fprintf('PsychoPhysics runs last %0.2f min. \n\n', [10+sum(SOAList)]/60) %#ok<NBRAK>
        end
        
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
        
        %% Compute efficiency
        if 1 %fMRI %&& RunInd==1
            clear S SOT_List PresTime_List
            
            S.bf = 'hrf';
            S.HC = 128;
            S.TR = 3;
            S.t0 = 3;
            
            SOT_List=cumsum(SOAList);
            
            S.CM{1} = [1 0 0 0 0 0 0];
            S.CM{2} = [0 1 0 0 0 0 0];
            S.CM{3} = [0 0 1 0 0 0 0];
            S.CM{4} = [0 0 0 1 0 0 0];
            S.CM{5} = [0 0 0 0 1 0 0];
            S.CM{6} = [0 0 0 0 0 1 0];
            
            S.sots{1} = SOT_List(all([TrialList==1 SideList==4],2))/S.TR; %A_L
            S.sots{2} = SOT_List(all([TrialList==2 SideList==4],2))/S.TR; %V_L
            S.sots{3} = SOT_List(all([TrialList==5 SideList==4],2))/S.TR; %T_L
            S.sots{4} = SOT_List(all([TrialList==1 SideList==12],2))/S.TR; %A_R
            S.sots{5} = SOT_List(all([TrialList==2 SideList==12],2))/S.TR; %V_R
            S.sots{6} = SOT_List(all([TrialList==5 SideList==12],2))/S.TR; %T_R
            S.sots{7} = SOT_List(TrialList>5)/S.TR;
            
            S.Ns = ceil(SOT_List(end)/S.TR)+5;
            
            fprintf('\nNumber of volumes: %i\n\n', S.Ns)
            
            [e, X] = fMRI_GLM_efficiency(S);
            
            figure('name', [Insert ' - Run: ' num2str(RunInd)], 'position', [100 100 1200 550])
            Colors = 'rgbcmyk';
            subplot(2,2,1)
            hold on
            for i=1:length(S.sots)
                stem(S.sots{i},ones(1,length(S.sots{i})), Colors(i))
            end
            axis([0 [10+sum(SOAList)]/S.TR 0 1.2]) %#ok<NBRAK>
            set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(10+sum(SOAList)) ,...
                'xticklabel', S.TR*(0:10:ceil(10+sum(SOAList))), ...
                'ticklength', [0.01 0.01], 'fontsize', 8)
            t=xlabel('Time (s)');
            set(t,'fontsize',8);
            
            subplot(2,2,3)
            hold on
            for i=1:length(S.sots)
                plot(X(:,i), Colors(i))
            end
            axis([0 [10+sum(SOAList)]/S.TR min(X(:)) max(X(:))]) %#ok<NBRAK>
            set(gca,'tickdir', 'out', 'xtick', 0:10:ceil(10+sum(SOAList)) ,...
                'xticklabel', S.TR*(0:10:ceil(10+sum(SOAList))), ...
                'ticklength', [0.01 0.01], 'fontsize', 8)
            t=xlabel('Time (s)');
            set(t,'fontsize',12);
            
            subplot(2,2,[2 4])
            colormap(gray)
            imagesc(X)
        end
        
        if any(Targets(:))
            error('targets missing')
        end
        
        %%
        RunNumber = RunInd + 3000;
        
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

