%%
clc; clear; close all;

Subjects = 17:19;

FigDim = [100 100 1200 550];

addpath(genpath(fullfile(pwd, 'subfun')))

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = linspace(-12,12,200); %0:.01:1;
searchGrid.beta = linspace(0,1,200);
searchGrid.gamma = 0;%scalar here (since fixed) but may be vector
searchGrid.lambda = 0:.01:1;  %ditto

%Threshold, Slope, and lapse rate are free parameters, guess rate is fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter

%Fit a Logistic function
PF = @PAL_CumulativeNormal;  %Alternatives: PAL_Gumbel, PAL_Weibull,
%PAL_CumulativeNormal, PAL_HyperbolicSecant, @PAL_Logistic

%Optional:
options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
options.TolFun = 1e-09;     %increase required precision on LL
options.MaxIter = 500;
options.Display = 'off';    %suppress fminsearch messages
lapseLimits = [0 1];        %limit range for lambda


IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    Angles = [-12, -10, -8, -5, -4, -3, -1, 0, 1, 3, 4, 5, 8, 10, 12];
    
    clear Accuracy AccuracyLeft AccuracyRight AccComp

    cd(fullfile(StartDirectory, 'Subjects_Data', strcat('Subject_', num2str(Subjects(SubjInd)))))
    
    mkdir('PsychCurv')
    
    copyfile('Logfile_*Run_500*.txt', 'PsychCurv')
    copyfile('Trial_List_Subject_*Run_500*.txt', 'PsychCurv')
    copyfile('Side_List_Subject_*Run_500*.txt', 'PsychCurv')
    
    cd('PsychCurv')
    
    for iFile = 1:length(dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_500*.txt')))
        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_500', num2str(iFile) ,'*.txt'));
        TrialList = load(TEMP.name);

        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_500', num2str(iFile) ,'*.txt'));
        AudioSide = load(TEMP.name);

        % Loads log file
        LogFile = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_500', num2str(iFile) ,'*.txt'));

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
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('PositiveFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('NegativeFeeback', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('BREAK', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AuditoryLocation', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        Resp = Stim_Time{1,1};
        TEMP = find(strcmp('AudioOnly_Trial_A', Stim_Time{1,1}));
        Resp(TEMP,:) = [];
        Resp = str2num(cell2mat(Resp));
        Resp(1)=[];
        clear TEMP
        
        if numel(Resp)~=numel(AudioSide)
            Resp = [];
            IsTrial=0;
            for i=1:length(Stim_Time{1,1})
                if strcmp('AudioOnly_Trial_A', Stim_Time{1,1}(i,:))
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

        Loc = unique(AudioSide);
        
        for iLoc=1:numel(Loc)   
            NumberCorrectPerLevel(iFile,Loc(iLoc))=sum(all([AudioSide==Loc(iLoc) Resp==2],2));
            TrialPerLevel(iFile,Loc(iLoc)) = sum(all([AudioSide==Loc(iLoc) ~isnan(Resp)],2));
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
    LabelsFineGrain = linspace(min(Angles),max(Angles),500);

        [paramsValues LL exitflag output] = PAL_PFML_Fit(Angles,NumberCorrectPerLevel, ...
        TrialPerLevel,searchGrid,paramsFree,PF,'searchOptions',options, ...
        'lapseLimits',lapseLimits);
    
    message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
    
    disp(message);
    message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
    disp(message);

    ProportionCorrectModel = PF(paramsValues, LabelsFineGrain);

    BiasInd = find(ProportionCorrectModel>=.5, 1, 'first');
    BiasInd = find(LabelsFineGrain>=paramsValues(1), 1, 'first');
    Bias = LabelsFineGrain(BiasInd);
    
    DerY = diff(ProportionCorrectModel);
    DerY = DerY(BiasInd);
    
    DerX = diff(LabelsFineGrain);
    DerX = DerX(BiasInd);
    
    Der = DerY / DerX;

    InterceptY = .5 - Bias * Der;
    
    
    %%
    figure('name', strcat('Subject ', sprintf('%02.0f', Subjects(SubjInd)), ' - PsychMetric functions - A'), ...
    'position', FigDim)

    hold on
    
    plot(Angles,NumberCorrectPerLevel./TrialPerLevel,'k.','markersize',30);
    plot(LabelsFineGrain,ProportionCorrectModel,'g-','linewidth',4);
    
    plot([0 0], [0 1], '--k','linewidth',1)
    plot([Angles(1) Angles(end)], [0.5 0.5], '--k','linewidth',1)
    plot([paramsValues(1) paramsValues(1)], [0 0.5], '-r','linewidth',1)
    

    
%     plot(LabelsFineGrain, LabelsFineGrain*Der+InterceptY, '-k')
    
    
    
    set(gca, 'xtick', Angles, 'xticklabel', Angles,...
        'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 12);
    axis([min(Angles) max(Angles) 0 1]);
    ylabel(['Subject  ', num2str(Subjects(SubjInd))]);
    xlabel('Angle (Deg)');
    t=title('Auditory: proportion right = f(angle)');
    
%     t=text(-10,.75, sprintf('PAL Bias: %02.2f deg VA', paramsValues(1)));
%     set(t,'fontsize',16)
    t=text(-10,.7, sprintf('Bias: %02.2f deg VA', Bias));
    set(t,'fontsize',16)
%     t=text(-10,.65, sprintf('PAL Slope: %02.2f / deg VA', paramsValues(2)));
%     set(t,'fontsize',16)
    t=text(-10,.6, sprintf('Slope: %02.2f / deg VA', Der));
    set(t,'fontsize',16)
    

    print(gcf, strcat('Subject_', sprintf('%02.0f', Subjects(SubjInd)), ...
        '_PsychMetric_functions_A.tif'), '-dtiff')

    SubjAll(SubjInd,1:4) = [paramsValues(1) Bias Der*paramsValues(2) Der*100];
    
    clear NumberCorrectPerLevel TrialPerLevel Loc
    
    %%
    cd(StartDirectory)

end

