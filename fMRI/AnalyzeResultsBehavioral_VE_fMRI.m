clc; clear; close all

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

addpath(genpath(fullfile(pwd,'subfun')))

% Subjects = [4:6 8:13 15:18];
Subjects = [7 14];
% Subjects = [1 2];

FigDim = [100 100 1200 550];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

COLOR =   [...
    255 255 0; ...
    0 255 255; ...
    255 0 255; ...
    150 150 150; ...
    255 75 75; ...
    255 0 0; ...
    0 255 0; ...
    0 0 255; ...
    0 0 0];
COLOR=COLOR/255;

mn = length(Subjects);
n  = round(mn^0.4);
m  = ceil(mn/n);

ColorSubjects =   [...
    166,206,227;...
    31,120,180;...
    178,223,138;...
    51,160,44;...
    251,154,153;...
    227,26,28;...
    253,191,111;...
    255,127,0;...
    202,178,214;...
    106,61,154;...
    255,255,153;...
    177,89,40;...
    255,0,0;...
    255,255,0;...
    255,0,255;...
    ];
ColorSubjects=ColorSubjects/255;

h(2) = figure('name', 'VE: Resp per loc - A', 'position', FigDim);
h(3) = figure('name', 'VE: Resp per loc - V_L', 'position', FigDim);
h(4) = figure('name', 'VE: Resp per loc - V_R', 'position', FigDim);

% h(5) = figure('name', 'VE 3 positions: Responses switch', 'position',
% [100 100 500 1000]);

% h(3) = figure('name', 'VE 3 positions: CMB per loc', 'position', [100 100 500 1000]);


for SubjInd = 1:length(Subjects)
    
    clear Data

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'fMRI'))

    FileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_20*.txt'));

    AccuracyCon =  nan(1,length(FileList));
    AccuracyInc =  nan(1,length(FileList));
    AccuracyA =  nan(1,length(FileList));

    CMB =  nan(1,length(FileList));

    MissedResp = nan(1,length(FileList));
    ExtraResp = zeros(1,length(FileList));

    RespPerLoc = nan(3,3,length(FileList));
    RespPerLocVl = nan(3,3,length(FileList));
    RespPerLocVr = nan(3,3,length(FileList));
    
    AvsV = cell(3,3,length(FileList));

    AllSOTs = cell(length(FileList),1);

    for iFile = 1:length(FileList)

        RunNumber = FileList(iFile).name(end-23:end-20);

        clear TrialList AudioSide VisualSide Resp RT

        % Loads trial type order presented
        TEMP = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_', RunNumber ,'*.txt'));
        TrialList = load(TEMP.name);


        % Loads side on which the auditory was presented
        TEMP = dir(strcat('Audio_Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_', RunNumber ,'*.txt'));
        AudioSide = load(TEMP.name);
        AudioSide(TrialList==0)=[];

        AudioSide(AudioSide==4) = -1;
        AudioSide(AudioSide==8) = 0;
        AudioSide(AudioSide==12) = 1;


        % Loads side on which the visual was presented
        TEMP = dir(strcat('Visual_Side_List_Subject_', num2str(Subjects(SubjInd)), '_Run_', RunNumber ,'*.txt'));
        VisualSide = load(TEMP.name);
        VisualSide(TrialList==0)=[];

        VisualSide(VisualSide==4) = -1;
        VisualSide(VisualSide==12) = 1;

        TrialListOri = TrialList;
        TrialList(TrialList==0)=[];


        % Loads log file
        LogFile = FileList(iFile).name;
        disp(LogFile)

        fid = fopen(fullfile (pwd, LogFile));
        FileContent = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', IndStart, 'returnOnError',0);
        fclose(fid);
        clear fid

        EOF = find(strcmp('Final_Fixation', FileContent{1,3}));
        if isempty(EOF)
            EOF = find(strcmp('Quit', FileContent{1,2})) - 1;
        end

        Stim_Time{1,1} = FileContent{1,3}(1:EOF);
        Stim_Time{1,2} = char(FileContent{1,4}(1:EOF));

        StartTime =  str2num(Stim_Time{1,2}(find(strcmp('Start', Stim_Time{1,1})),:));
        EndTime =  str2num(Stim_Time{1,2}(find(strcmp('Final_Fixation', Stim_Time{1,1})),:));
        Duration = (EndTime - StartTime)/600000

        TEMP = find(strcmp('30', Stim_Time{1,1}));
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('4', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Inc_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioVisual_Con_Trial_V', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('AudioOnly_Trial_V', Stim_Time{1,1}))];


        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        NbTrial=numel(TrialList);

        MissingTrial = NbTrial-sum (strcmp('AudioVisual_Con_Trial_A', Stim_Time{1,1}) + ...
            strcmp('AudioVisual_Inc_Trial_A', Stim_Time{1,1}) + ...
            strcmp('AudioOnly_Trial_A', Stim_Time{1,1}));

        if MissingTrial
            warning('WE ARE MISSING %i TRIALS!!!!', MissingTrial)
        end

        Resp = nan(NbTrial,1);
        RT = nan(NbTrial,1);

        NbResp = sum(strcmp('1', Stim_Time{1,1}) + strcmp('2', Stim_Time{1,1}) + strcmp('3', Stim_Time{1,1}));

        iTrial = 0;
        IsTrial = 0;

        for i=1:length(Stim_Time{1,1})

            if strcmp('AudioVisual_Con_Trial_A', Stim_Time{1,1}(i,:)) || ...
                    strcmp('AudioVisual_Inc_Trial_A', Stim_Time{1,1}(i,:)) || ...
                    strcmp('AudioOnly_Trial_A', Stim_Time{1,1}(i,:))
                iTrial = iTrial+1;
                IsTrial = 1;
                TEMP = str2num(char(Stim_Time{1,2}(i,:)));

                AllSOTs{iFile,1}(end+1) = (TEMP - StartTime)/10000;

            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) || strcmp('3', Stim_Time{1,1}(i,:))
                if IsTrial
                    Resp(iTrial,1) = str2num(char(Stim_Time{1,1}(i,:)));
                    RT(iTrial,1) = (str2num(Stim_Time{1,2}(i,:)) - TEMP)/10000;
                    IsTrial=0;
                else
                    ExtraResp(iFile)=ExtraResp(iFile)+1;
                end
            end
        end

        
        if sum(~isnan(Resp))+ExtraResp ~= NbResp
            error('We are missing some responses.')
        end

        
        Resp(Resp==1)=-1;
        Resp(Resp==2)=0;
        Resp(Resp==3)=1;

        
        Data{iFile} = [TrialList AudioSide VisualSide Resp RT];

        
        ValidTrials = ~isnan(Resp);

        
        for A = -1:1
            for V = -1:1
                tmp = Data{iFile}(all([Data{iFile}(ValidTrials,2)==A Data{iFile}(ValidTrials,3)==V],2),4);
                AvsV{V+2,A+2,iFile}(1) = sum(tmp==-1)/numel(tmp);
                AvsV{V+2,A+2,iFile}(2) = sum(tmp==0)/numel(tmp);
                AvsV{V+2,A+2,iFile}(3) = sum(tmp==1)/numel(tmp);
            end
        end
        

        for i = -1:1
            tmp = Data{iFile}(all([Data{iFile}(ValidTrials,2)==i Data{iFile}(ValidTrials,1)==1],2),4);
            RespPerLoc(i+2,1,iFile) = sum(tmp==-1);
            RespPerLoc(i+2,2,iFile) = sum(tmp==0);
            RespPerLoc(i+2,3,iFile) = sum(tmp==1);

            tmp = Data{iFile}(all([Data{iFile}(ValidTrials,2)==i Data{iFile}(ValidTrials,3)==-1],2),4);
            RespPerLocVl(i+2,1,iFile) = sum(tmp==-1);
            RespPerLocVl(i+2,2,iFile) = sum(tmp==0);
            RespPerLocVl(i+2,3,iFile) = sum(tmp==1);

            tmp = Data{iFile}(all([Data{iFile}(ValidTrials,2)==i Data{iFile}(ValidTrials,3)==1],2),4);
            RespPerLocVr(i+2,1,iFile) = sum(tmp==-1);
            RespPerLocVr(i+2,2,iFile) = sum(tmp==0);
            RespPerLocVr(i+2,3,iFile) = sum(tmp==1);
        end

        
        AccuracyCon(iFile) = sum(any([...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([3 -1 -1],sum(ValidTrials),1),2), ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([3 0 0],sum(ValidTrials),1),2), ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([3 1 1],sum(ValidTrials),1),2)] ...
            , 2))/sum(Data{iFile}(ValidTrials,1)==3);

        
        AccuracyInc(iFile) = sum(any([...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([4 -1 -1],sum(ValidTrials),1),2), ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([4 0 0],sum(ValidTrials),1),2), ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([4 1 1],sum(ValidTrials),1),2), ...
            ], 2))/sum(Data{iFile}(ValidTrials,1)==4);

        
        AccuracyA(iFile) = sum(any([...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([1 -1 -1],sum(ValidTrials),1),2) ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([1 0 0],sum(ValidTrials),1),2) ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([1 1 1],sum(ValidTrials),1),2) ...
            ], 2))/sum(Data{iFile}(ValidTrials,1)==1);

        
        ValidTrials = all([~isnan(Resp) Data{iFile}(:,1)==4],2);

        
        CMB(iFile) = nanmean((Data{iFile}(ValidTrials,4) - Data{iFile}(ValidTrials,2))./ ...
            (Data{iFile}(ValidTrials,3) - Data{iFile}(ValidTrials,2)));

        
        tmp = diff(AllSOTs{iFile,1});
        tmp(tmp>6) = [];
        fprintf('SOA = %f +/- %f secs\n\n', mean(tmp), std(tmp))


        MissedResp(iFile) = (sum(isnan((Data{iFile}(:,4))))-MissingTrial)/(size(Data{iFile}(:,4),1)-MissingTrial);

    end


    for iFile=1:size(Data,2)

        if MissedResp(iFile)>.05
            figure('name', ['Subject ' num2str(Subjects(SubjInd)) ' - missed answers for run ' num2str(iFile)], ...
                'position', FigDim)

            hold on
            grid on

            plot(~isnan(Data{iFile}(:,4)), 'b')

            axis([0 length(Data{iFile}(:,4)) 0 1.1])
            set(gca, 'ytick', 0:1, 'yticklabel',  0:1)
            ylabel('Missed responses');
            xlabel('Trials');
            
            print(gcf, ['Subject' num2str(Subjects(SubjInd)) '_MissedResp_Run_' num2str(iFile) '.tif'], '-dtiff')
        end
        
    end


    MissedResp
    ExtraResp

    AccuracyAll(SubjInd,:) = [nanmean(AccuracyA) nanmean(AccuracyCon) nanmean(AccuracyInc)];

    
    figure('name', ['Subject ' num2str(Subjects(SubjInd)) ' - A_vs_V_AnswerProb'], ...
                'position', FigDim)
    SubPlot = 1;
    for V = 1:3
        for A = 1:3
            
            clear tmp
            for iFile=1:size(AvsV,3)
                tmp(iFile,1:3)=AvsV{V,A,iFile}
            end
            
            subplot(3,3,SubPlot)
            if size(AvsV,3)>1
                errorbar(1:3, mean(tmp), nansem(tmp), 'linewidth', 2)
            else
                plot(1:3, tmp, 'linewidth', 2)
            end
 
            set(gca, 'ytick', 0:.25:1, 'yticklabel', 0:.25:1, ...
                'xtick', 1:3, 'xticklabel', [-5 0 5])
            axis([0.9 3.1 0 1])
            grid on

            if SubPlot>6; xlabel('Response location'); end
            
            if SubPlot==1; ylabel(sprintf('V_L\n\nProbability')); end
            if SubPlot==4; ylabel(sprintf('V_0\n\nProbability')); end
            if SubPlot==7; ylabel(sprintf('V_R\n\nProbability')); end     
            
            if SubPlot==1; title(sprintf('A_L')); end
            if SubPlot==2; title(sprintf('A_C')); end
            if SubPlot==3; title(sprintf('A_R')); end 
            
            SubPlot=SubPlot+1;
        end
    end
    print(gcf, ['Subject' num2str(Subjects(SubjInd)) '-A_vs_V_AnswerProb.tif'], '-dtiff')

    
    RespPerLoc = nanmean(RespPerLoc,3);
    for i = 1:size(RespPerLoc,1)
        RespPerLoc(i,:) = RespPerLoc(i,:)/sum(RespPerLoc(i,:))
    end
    RespPerLocAll(:,:,SubjInd) = RespPerLoc;

    figure(h(2))
    subplot(m,n,SubjInd)
    colormap('hot')
    imagesc(RespPerLoc, [0 1])
    ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd))]));
    %     ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd)) '\nTrue A
    %     location']));
    %     xlabel('Responded A location');
    %     set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    %         'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
    set(gca, 'ytick', 1:3, 'yticklabel', {''}, ...
        'xtick', 1:3, 'xticklabel', {''})


    RespPerLocVl = nanmean(RespPerLocVl,3);
    for i = 1:size(RespPerLoc,1)
        RespPerLocVl(i,:) = RespPerLocVl(i,:)/sum(RespPerLocVl(i,:))
    end
    RespPerLocVlAll(:,:,SubjInd) = RespPerLocVl;

    figure(h(3))
    subplot(m,n,SubjInd)
    colormap('hot')
    imagesc(RespPerLocVl, [0 1])
    ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd))]));
    %     ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd)) '\nTrue A
    %     location']));
    %     xlabel('Responded A location');
    %     set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    %         'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
    set(gca, 'ytick', 1:3, 'yticklabel', {''}, ...
        'xtick', 1:3, 'xticklabel', {''})


    RespPerLocVr = nanmean(RespPerLocVr,3);
    for i = 1:size(RespPerLoc,1)
        RespPerLocVr(i,:) = RespPerLocVr(i,:)/sum(RespPerLocVr(i,:))
    end
    RespPerLocVrAll(:,:,SubjInd) = RespPerLocVr;

    figure(h(4))
    colormap('hot')
    subplot(m,n,SubjInd)
    imagesc(RespPerLocVr, [0 1])
    ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd))]));
    %     ylabel(sprintf(['Subject  ' num2str(Subjects(SubjInd)) '\nTrue A location']));
    %     xlabel('Responded A location');
    %     set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    %         'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
    set(gca, 'ytick', 1:3, 'yticklabel', {''}, ...
        'xtick', 1:3, 'xticklabel', {''})


    figure('name', ['Subject ' num2str(Subjects(SubjInd))], 'position', FigDim)
    hold on
    grid on

    bar(MissedResp)
    plot(AccuracyCon, '-+b')
    plot(AccuracyInc, '-+r')
    plot(AccuracyA, '-+k')
    plot(CMB, '-og')
    t=legend(char({'Missed';'AccuracyCon';'AccuracyInc';'AccuracyA';'CMB'}),...
        'Location','SouthWest');
    set(t,'Fontsize',8)

    errorbar(0, nanmean(AccuracyCon), nansem(AccuracyCon), '-b', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'b')
    errorbar(0, nanmean(AccuracyInc), nansem(AccuracyInc), '-r', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'r')
    errorbar(0, nanmean(AccuracyA), nansem(AccuracyA), '-k', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'k')
    errorbar(0, nanmean(CMB), nansem(CMB), '-g', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'g')

    if Subjects(SubjInd)==1
        plot([7.5 7.5],[0 1],'k','LineWidth',2)
    elseif Subjects(SubjInd)==2
        plot([6.5 6.5],[0 1],'k','LineWidth',2)
    end

    axis([-0.5 length(AccuracyInc)+.5 0 1])

    set(gca, 'xtick', 0:length(AccuracyInc), 'xticklabel', {'Mean',1:length(AccuracyInc)}, ...
        'ytick', 0:.1:1, 'yticklabel', 0:10:100 )
    xlabel('Run')

    cd(StartDirectory)

    print(gcf, ['VE_fMRI_Subject ' num2str(Subjects(SubjInd)) '.tif'], '-dtiff')

end % SubjInd = 1:length(Subjects)

figure(h(2))
print(gcf, 'VE_RespPerLoc_A.tif', '-dtiff')

figure(h(3))
print(gcf, 'VE_RespPerLoc_V_L.tif', '-dtiff')

figure(h(4))
print(gcf, 'VE_RespPerLoc_V_R.tif', '-dtiff')


figure('name', 'VE: Acc', 'position', FigDim);
hold on
errorbar([0 2:3],  mean(AccuracyAll), nansem(AccuracyAll), ' o','LineWidth', 2)
plot([0 2:3], mean(AccuracyAll),'MarkerFaceColor',[0 0 1],'Marker','o','LineStyle','none',...
    'Color',[0 0 1], 'MarkerSize', 10)
for iSubj=1:size(AccuracyAll,1)
    plot([0 2:3]+.1+iSubj/20, AccuracyAll(iSubj,:),'MarkerFaceColor',ColorSubjects(iSubj,:),'Marker','o','LineStyle','none',...
        'Color',ColorSubjects(iSubj,:), 'MarkerSize', 5)
end
axis([-0.5 4 0 1])
set(gca, 'ytick', 0:.25:1, 'yticklabel', 0:25:100, 'xtick', 0:3, ...
    'xticklabel', {'AccA','','AccCon','AccInc'})
t=ylabel('Accuracy');
print(gcf, 'VE_Acc.tif', '-dtiff')

figure('name', 'VE: MEAN resp per loc - A', 'position', FigDim)
colormap('hot')
imagesc(mean(RespPerLocAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
print(gcf, 'VE_MEAN_RespPerLoc_A.tif', '-dtiff')

figure('name', 'VE: MEAN resp per loc - V_L', 'position', FigDim);
colormap('hot')
imagesc(mean(RespPerLocVlAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
print(gcf, 'VE_MEAN_RespPerLoc_V_L.tif', '-dtiff')

figure('name', 'VE: MEAN resp per loc - V_R', 'position', FigDim);
colormap('hot')
imagesc(mean(RespPerLocVrAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
print(gcf, 'VE_MEAN_RespPerLoc-V_R.tif', '-dtiff')


% close all
% figure(1)
% for i=1:9
%     hold on
%     plot(1:2,1:2, 'color', COLOR(i,:), 'linewidth', 2)
% end
% LEGEND={...
%     'A_L    ';...
%     'A_C    ';...
%     'A_R    ';...
%     'A_L-V_L';...
%     'A_C-V_L';...
%     'A_R-V_L';...
%     'A_L-V_R';...
%     'A_C-V_R';...
%     'A_R-V_R'};
% legend(LEGEND)