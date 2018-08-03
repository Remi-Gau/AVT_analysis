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

% Subjects = [4:6 9:13 15:18];
Subjects = [7 14];
% % Subjects = [1 2 3];

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


for SubjInd = 1:length(Subjects)

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'PsyPhy'))

    FileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_210*.txt'));

    AccuracyCon =  nan(1,length(FileList));
    AccuracyInc =  nan(1,length(FileList));
    AccuracyA =  nan(1,length(FileList));

    CMB =  nan(1,length(FileList));
    CMB_Same =  nan(1,length(FileList));
    CMB_Diff =  nan(1,length(FileList));

    PercComCon =  nan(1,length(FileList));
    PercComInc =  nan(1,length(FileList));

    MissedResp = nan(1,length(FileList));
    ExtraResp = zeros(1,length(FileList));

    RespPerLoc = nan(3,3,length(FileList));
    RespPerLocVl = nan(3,3,length(FileList));
    RespPerLocVr = nan(3,3,length(FileList));
    
    AvsV = cell(3,3,3,length(FileList));

    for iFile = 1:length(FileList)

        RunNumber = FileList(iFile).name(end-23:end-20);

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

        TEMP = find(strcmp('30', Stim_Time{1,1}));
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('6', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('BREAK', Stim_Time{1,1}))];
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

        AudLocResp = nan(NbTrial,1);
        AudLocRT = nan(NbTrial,1);
        ComSrcResp = nan(NbTrial,1);
        ComSrcRT = nan(NbTrial,1);
        
        NbResp = sum (strcmp('1', Stim_Time{1,1}) + strcmp('2', Stim_Time{1,1}) + ...
                strcmp('3', Stim_Time{1,1}) + strcmp('4', Stim_Time{1,1}) + ...
                strcmp('5', Stim_Time{1,1}));
            
        iTrial = 0;
        ComSrc = 0;
        AudLoc = 0;

        for i=1:length(Stim_Time{1,1})
            if strcmp('AudioVisual_Con_Trial_A', Stim_Time{1,1}(i,:)) || ...
                    strcmp('AudioVisual_Inc_Trial_A', Stim_Time{1,1}(i,:)) || ...
                    strcmp('AudioOnly_Trial_A', Stim_Time{1,1}(i,:))
                ComSrc = 1;
                AudLoc = 1;
                TEMP1 = 0;
                TEMP2 = 0;
                iTrial = iTrial+1;

            elseif strcmp('AuditoryLocation', Stim_Time{1,1}(i,:))
                TEMP1 = str2num(char(Stim_Time{1,2}(i,:)));

            elseif strcmp('CommonSource', Stim_Time{1,1}(i,:))
                TEMP2 = str2num(char(Stim_Time{1,2}(i,:)));

            elseif strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) ...
                    || strcmp('3', Stim_Time{1,1}(i,:)) || strcmp('4', Stim_Time{1,1}(i,:)) || strcmp('5', Stim_Time{1,1}(i,:))
                if AudLoc
                    if strcmp('1', Stim_Time{1,1}(i,:)) || strcmp('2', Stim_Time{1,1}(i,:)) || strcmp('3', Stim_Time{1,1}(i,:))
                        AudLoc=0;
                        ComSrc = 1;
                        AudLocResp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                        if TEMP1>0;
                            AudLocRT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP1)/10000;
                        end
                    else
                        ExtraResp(iFile)=ExtraResp(iFile)+1;
                    end
                elseif ComSrc
                    if strcmp('4', Stim_Time{1,1}(i,:)) || strcmp('5', Stim_Time{1,1}(i,:))
                        AudLoc=0;
                        ComSrc=0;
                        ComSrcResp(iTrial) = str2num(char(Stim_Time{1,1}(i,:)));
                        if TEMP2>0
                            ComSrcRT(iTrial) = (str2num(Stim_Time{1,2}(i,:)) - TEMP2)/10000;
                        end
                    else
                        ExtraResp(iFile)=ExtraResp(iFile)+1;
                    end
                else
                    ExtraResp(iFile)=ExtraResp(iFile)+1;
                end
            end
        end

        if sum(~isnan(AudLocResp)+~isnan(ComSrcResp))+ExtraResp(iFile) ~= NbResp    
            error('We are missing some responses.')
        end


        AudLocResp(AudLocResp==1)=-1;
        AudLocResp(AudLocResp==2)=0;
        AudLocResp(AudLocResp==3)=1;

        ComSrcResp(ComSrcResp==4)=1;
        ComSrcResp(ComSrcResp==5)=0;



        % Compiles data
        % Trial type // True Audio Loc // True Visual Loc // Resp Audio Loc // RT Resp Audio // Com Source // RT Com Source
        % Trial type : 3 --> CON ; 4 --> INC
        % True Audio Loc : -1 --> Left ; 1 --> Right
        % Resp Audio Loc : -1 --> Left ; 1 --> Right
        % Com Source : 1 --> Same ; 0 --> Different

        Data{iFile} = [TrialList AudioSide VisualSide AudLocResp AudLocRT ComSrcResp ComSrcRT];

        ValidTrials = ~isnan(AudLocResp);
        
        
        for A = -1:1
            for V = -1:1
                tmp = Data{iFile}(all([
                    Data{iFile}(ValidTrials,2)==A ...
                    Data{iFile}(ValidTrials,3)==V ...
                    Data{iFile}(ValidTrials,6)==1 ...
                    Data{iFile}(ValidTrials,1)~=1],2),4);
                AvsV{V+2,A+2,1,iFile}(1) = sum(tmp==-1)/numel(tmp);
                AvsV{V+2,A+2,1,iFile}(2) = sum(tmp==0)/numel(tmp);
                AvsV{V+2,A+2,1,iFile}(3) = sum(tmp==1)/numel(tmp);

                tmp = Data{iFile}(all([
                    Data{iFile}(ValidTrials,2)==A ...
                    Data{iFile}(ValidTrials,3)==V ...
                    Data{iFile}(ValidTrials,6)==0 ...
                    Data{iFile}(ValidTrials,1)~=1],2),4);
                AvsV{V+2,A+2,2,iFile}(1) = sum(tmp==-1)/numel(tmp);
                AvsV{V+2,A+2,2,iFile}(2) = sum(tmp==0)/numel(tmp);
                AvsV{V+2,A+2,2,iFile}(3) = sum(tmp==1)/numel(tmp);     
                
                tmp = Data{iFile}(all([
                    Data{iFile}(ValidTrials,2)==A ...
                    Data{iFile}(ValidTrials,3)==V ...
                    Data{iFile}(ValidTrials,1)==1],2),4);
                AvsV{V+2,A+2,3,iFile}(1) = sum(tmp==-1)/numel(tmp);
                AvsV{V+2,A+2,3,iFile}(2) = sum(tmp==0)/numel(tmp);
                AvsV{V+2,A+2,3,iFile}(3) = sum(tmp==1)/numel(tmp);                 
                
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
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([3 -1 -1],sum(ValidTrials),1),2) ...
            all(Data{iFile}(ValidTrials,[1 2 4])==repmat([3 1 1],sum(ValidTrials),1),2)...
            ], 2))/sum(Data{iFile}(ValidTrials,1)==3);

        AccuracyInc(iFile) = sum(any([...
            all(Data{iFile}(:,[1 2 4])==repmat([4 -1 -1],sum(ValidTrials),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([4 0 0],sum(ValidTrials),1),2)...
            all(Data{iFile}(:,[1 2 4])==repmat([4 1 1],sum(ValidTrials),1),2)...
            ], 2))/sum(Data{iFile}(ValidTrials,1)==4);

        AccuracyA(iFile) = sum(any([...
            all(Data{iFile}(:,[1 2 4])==repmat([1 -1 -1],sum(ValidTrials),1),2) ...
            all(Data{iFile}(:,[1 2 4])==repmat([1 0 0],sum(ValidTrials),1),2)...
            all(Data{iFile}(:,[1 2 4])==repmat([1 1 1],sum(ValidTrials),1),2)...
            ], 2))/sum(Data{iFile}(ValidTrials,1)==1);

        
        ValidTrials = all([~isnan(AudLocResp) Data{iFile}(:,1)==4],2);
        CMB(iFile) = nanmean((Data{iFile}(ValidTrials,4) - Data{iFile}(ValidTrials,2))./ ...
            (Data{iFile}(ValidTrials,3) - Data{iFile}(ValidTrials,2)));
        
        
        ValidTrials = all([~isnan(ComSrcResp) Data{iFile}(:,1)==3 ],2);
        PercComCon(iFile) = sum(all(Data{iFile}(ValidTrials,[1 6])==repmat([3 1],sum(ValidTrials),1),2))/sum(Data{iFile}(ValidTrials,1)==3);
        
        ValidTrials = all([~isnan(ComSrcResp) Data{iFile}(:,1)==4 ],2);
        PercComInc(iFile) = sum(all(Data{iFile}(ValidTrials,[1 6])==repmat([4 1],sum(ValidTrials),1),2))/sum(Data{iFile}(ValidTrials,1)==4);

        
        ValidTrials = all([~isnan(AudLocResp) Data{iFile}(:,1)==4 Data{iFile}(:,6)==1],2);
        CMB_Same(iFile) = mean( ...
            (Data{iFile}(ValidTrials,4) - Data{iFile}(ValidTrials,2))./ ...
            (Data{iFile}(ValidTrials,3) - Data{iFile}(ValidTrials,2)) ...
            );

        ValidTrials = all([~isnan(AudLocResp) Data{iFile}(:,1)==4 Data{iFile}(:,6)==0],2);
        CMB_Diff(iFile) = mean( ...
            (Data{iFile}(ValidTrials,4) - Data{iFile}(ValidTrials,2))./ ...
            (Data{iFile}(ValidTrials,3) - Data{iFile}(ValidTrials,2)) ...
            );

    end

    %%
    MissedResp
    ExtraResp
    
    AccuracyAll(SubjInd,:) = [nanmean(AccuracyA) nanmean(AccuracyCon) nanmean(AccuracyInc)];
    
    
    figure('name', ['Subject ' num2str(Subjects(SubjInd)) ' - A_vs_V_AnswerProb_PsyPhy'], ...
                'position', FigDim)
    SubPlot = 1;
    for V = 1:3
        for A = 1:3
            
            clear tmp tmp2 tmp3
            for iFile=1:size(AvsV,4)
                tmp(iFile,1:3)=AvsV{V,A,1,iFile}; 
                tmp2(iFile,1:3)=AvsV{V,A,2,iFile}; 
                tmp3(iFile,1:3)=AvsV{V,A,3,iFile};
            end
            
            subplot(3,3,SubPlot)
            hold on
            if size(AvsV,4)>1
                errorbar(1:3, mean(tmp), nansem(tmp), 'b', 'linewidth', 2)
                errorbar(1:3, mean(tmp2), nansem(tmp2), 'g', 'linewidth', 2)
                errorbar(1:3, mean(tmp3), nansem(tmp3), 'r', 'linewidth', 2)
            else
                plot(1:3, tmp, 'b', 'linewidth', 2)
                plot(1:3, tmp2, 'g', 'linewidth', 2)
                plot(1:3, tmp3, 'r', 'linewidth', 2)
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
    print(gcf, ['Subject' num2str(Subjects(SubjInd)) '-A_vs_V_AnswerProb_PsyPhy.tif'], '-dtiff')

    
    
    
    RespPerLoc = nanmean(RespPerLoc,3);
    RespPerLoc = RespPerLoc/sum(RespPerLoc(1,:))
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
    RespPerLocVl = RespPerLocVl/sum(RespPerLocVl(1,:))
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
    RespPerLocVr =RespPerLocVr/sum(RespPerLocVr(1,:))
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
    
    if ~isempty(MissedResp)
        bar(MissedResp)
    end
    
    plot(AccuracyCon, '-+b')
    plot(AccuracyInc, '-+r')
    plot(AccuracyA, '-+k')

    plot(CMB_Same, '-og')
    plot(CMB_Diff, '.-g')
    
%     plot(PercComCon, '-ob')
%     plot(PercComInc, '-or')
    
    legend(char({'Missed';'AccuracyCon';'AccuracyInc';'AccuracyA';'CMB-Same';'CMB-Diff'}),...
        'Location','SouthWest')
    
    errorbar(0, nanmean(AccuracyCon), nansem(AccuracyCon), '-b', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'b')
    errorbar(0, nanmean(AccuracyInc), nansem(AccuracyInc), '-r', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'r')
    errorbar(0, nanmean(AccuracyA), nansem(AccuracyA), '-k', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'k')
    
    errorbar(0, nanmean(CMB_Same), nansem(CMB_Same), '-g', 'Marker','o',...
        'MarkerSize', 5, 'MarkerFaceColor', 'g')
    errorbar(0, nanmean(CMB_Diff), nansem(CMB_Diff), '-g', 'Marker','.',...
        'MarkerSize', 5, 'MarkerFaceColor', 'g')

    
    if Subjects(SubjInd)==1
        plot([7.5 7.5],[0 1],'k','LineWidth',2)
    elseif Subjects(SubjInd)==2
        plot([6.5 6.5],[0 1],'k','LineWidth',2)
    end

    axis([-0.5 length(AccuracyInc)+.5 0 1])

    tmp = {'AccuracyCon';'AccuracyInc';'AccuracyA';'CMB'};

    set(gca, 'xtick', 1:length(AccuracyInc), 'xticklabel', 1:length(AccuracyInc))
    xlabel('Run')
    
    cd(StartDirectory)

    print(gcf, ['VE_PsyPhy_Subject ' num2str(Subjects(SubjInd)) '.tif'], '-dtiff')

end

figure(h(2))
print(gcf, 'VE_PsyPhy_RespPerLoc_A.tif', '-dtiff')

figure(h(3))
print(gcf, 'VE_PsyPhy_RespPerLoc_V_L.tif', '-dtiff')

figure(h(4))
print(gcf, 'VE_PsyPhy_RespPerLoc_V_R.tif', '-dtiff')


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
set(gca, 'ytick', 0:.25:1, 'yticklabel', 0:.25:1, 'xtick', 0:3, ...
    'xticklabel', {'AccA','','AccCon','AccInc'})
t=ylabel('Accuracy');
print(gcf, 'VE_PsyPhy_Acc.tif', '-dtiff')

figure('name', 'VE: MEAN resp per loc - A', 'position', FigDim)
colormap('hot')
imagesc(mean(RespPerLocAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
print(gcf, 'VE_PsyPhy_MEAN_RespPerLoc_A.tif', '-dtiff')

figure('name', 'VE: MEAN resp per loc - V_L', 'position', FigDim);
colormap('hot')
imagesc(mean(RespPerLocVlAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
print(gcf, 'VE_PsyPhy_MEAN_RespPerLoc_V_L.tif', '-dtiff')

figure('name', 'VE: MEAN resp per loc - V_R', 'position', FigDim);
colormap('hot')
imagesc(mean(RespPerLocVrAll,3), [0 1])
colorbar
ylabel(sprintf(['MEAN' '\nTrue A location']));
xlabel('Responded A location');
set(gca, 'ytick', 1:3, 'yticklabel', {'Left';'Center';'Right'}, ...
    'xtick', 1:3, 'xticklabel', {'Left';'Center';'Right'})
print(gcf, 'VE_PsyPhy_MEAN_RespPerLoc_V_R.tif', '-dtiff')