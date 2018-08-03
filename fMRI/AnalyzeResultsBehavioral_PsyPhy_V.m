%%
clc; clear all; close all;

% Number	Name	ID
% 1	Stefan Kraemer	19717.75
% 2	Sissy Weiske	13565.7c
% 3	Paul Bulano	19017.5e
% 
% 4	Jan Budesheim	26634.fc
% 5	Max Winkler	18256.89
% 6	Anja Guenther	9/14/55
% 7	Stefan Kraemer	19717.75
% 8	Konrad Didt	25997.23
% 9	Ralf Junger	28031.51
% 10	Elisabeth Sellenriek	28705.2b
% 11	Paul Bulano	19017.5e
% 12	Julia Heinz	19883.56
% 13	Linda Knauerhase	26923.fd
% 14	Sissy Weiske	13565.7c
% 15	Anja Buettner-Janner	26140.f5
% 16	Anja Luedtke	24533.8f
% 17	Andre Diers	22768.81
% 18	Paul Vogel	26635.27
% 19	Stefanie Roetz	26821.88

Subjects = [4:6 8:13 15:18];
% Subjects = [7 14];
% Subjects = [1 2 3];

FigDim = [100 100 1200 550];

addpath(genpath(fullfile(pwd, 'subfun')))

% message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
ParOrNonPar = 1; %input(message);
%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0:.01:1;
searchGrid.beta = logspace(1,3,200);
searchGrid.gamma = 0;%scalar here (since fixed) but may be vector
searchGrid.lambda = 0:.01:1;  %ditto

%Threshold, Slope, and lapse rate are free parameters, guess rate is fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter

%Fit a Logistic function
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
%PAL_CumulativeNormal, PAL_HyperbolicSecant, @PAL_Logistic

%Optional:
options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
options.TolFun = 1e-09;     %increase required precision on LL
options.MaxIter = 400;
options.Display = 'off';    %suppress fminsearch messages
lapseLimits = [0 1];        %limit range for lambda


IndStart = 5;% first row of data points in txt file

figure('name', 'PsychMetric functions - V', ...
    'position', FigDim)

mn = length(Subjects);
n  = round(mn^0.4);
m  = ceil(mn/n);

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    Angles = [-12, -10, -8, -5, -4, -3, -1, 0, 1, 3, 4, 5, 8, 10, 12];
    
    clear Accuracy AccuracyLeft AccuracyRight AccComp

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'PsyPhy'))

    for iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_600*.txt')))
        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_600', num2str(iFile) ,'*.txt'));
        TrialList = load(TEMP.name);

        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_600', num2str(iFile) ,'*.txt'));
        VisualSide = load(TEMP.name);

        % Loads log file
        LogFile = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_600', num2str(iFile) ,'*.txt'));

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
        TEMP = [TEMP ; find(strcmp('3', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        


        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        Resp = Stim_Time{1,1};
        TEMP = find(strcmp('VisualOnly_Trial', Stim_Time{1,1}));
        Resp(TEMP,:) = [];
        Resp = str2num(cell2mat(Resp));
        clear TEMP
        
        if numel(Resp)~=numel(VisualSide)
            Resp = [];
            IsTrial=0;
            for i=1:length(Stim_Time{1,1})
                if strcmp('VisualOnly_Trial', Stim_Time{1,1}(i,:))
                    if IsTrial==1;
                        Resp(end+1,1)=NaN;
                    end
                    IsTrial = 1;
                else
                    if IsTrial==1;
                        Resp(end+1,1)=str2num(cell2mat(Stim_Time{1,1}(i,:)));
                        IsTrial=0;
                    end
                end
            end
        end

        Loc = unique(VisualSide);
        
        for iLoc=1:numel(Loc)   
            NumberCorrectPerLevel(iFile,Loc(iLoc))=sum(all([VisualSide==Loc(iLoc) Resp==2],2));
            TrialPerLevel(iFile,Loc(iLoc)) = sum(all([VisualSide==Loc(iLoc) ~isnan(Resp)],2));
        end
        
    end
    
    NumberCorrectPerLevel
    TrialPerLevel
    
    
    %%
    if size(NumberCorrectPerLevel,1)>1
        NumberCorrectPerLevel = sum(NumberCorrectPerLevel);
        TrialPerLevel = sum(TrialPerLevel);
    end
    
    if any(TrialPerLevel==0)
        NumberCorrectPerLevel(TrialPerLevel==0)=[];
        Angles(TrialPerLevel==0)=[];
        TrialPerLevel(TrialPerLevel==0)=[];
    end
    
    % Psychometric curve
    LevelsUsedFineGrain=linspace(min(Loc),max(Loc),300);

    [paramsValues LL exitflag output] = PAL_PFML_Fit(Loc',NumberCorrectPerLevel, ...
        TrialPerLevel,searchGrid,paramsFree,PF,'searchOptions',options, ...
        'lapseLimits',lapseLimits);

    ProportionCorrectModel = PF(paramsValues, LevelsUsedFineGrain);


    
    subplot(m,n,SubjInd)
    hold on
    
    plot(Loc,NumberCorrectPerLevel./TrialPerLevel,'k.','markersize',30);
    plot(LevelsUsedFineGrain,ProportionCorrectModel,'g-','linewidth',4);
    
    plot([8 8], [0 1], '--k','linewidth',1)
    plot([Loc(1) Loc(end)], [0.5 0.5], '--k','linewidth',1)
    plot([LevelsUsedFineGrain(find(ProportionCorrectModel>=.5, 1, 'first')) ...
        LevelsUsedFineGrain(find(ProportionCorrectModel>=.5, 1, 'first'))], [0 0.5], '-r','linewidth',1)
    
    set(gca, 'xtick', Loc, 'xticklabel', Angles,...
        'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 12);
    axis([min(Loc) max(Loc) 0 1]);
    ylabel(['Subject  ', num2str(Subjects(SubjInd))]);
%     xlabel('Angle (Deg)');
%     t=title('Auditory: proportion right = f(angle)');


    clear NumberCorrectPerLevel TrialPerLevel Loc
    
    %%
    cd(StartDirectory)

end

