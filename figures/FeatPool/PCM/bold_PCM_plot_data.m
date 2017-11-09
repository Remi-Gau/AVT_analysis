function bold_PCM_plot_data

clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')

surf = 0; % run of volumne whole ROI or surface profile data
raw = 1; % run on raw betas or prewhitened
hs_idpdt = 0;

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);


if surf
    %     ToPlot={'Cst','Lin','Quad'};
    ToPlot={'Cst'};
    Output_dir = 'surf';
else
    ToPlot={'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol'; %#ok<*NASGU>
    if raw
        if hs_idpdt
            Save_suffix = 'raw_betas';
        else
            Save_suffix = 'beta-raw';
        end
    else
        if hs_idpdt
            Save_suffix = 'whitened_betas';
        else
            Save_suffix = 'beta-wht'; %#ok<*UNRCH>
        end
    end
end

if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end

if hs_idpdt
    hs_suffix = {'LHS' 'RHS'};
else
    hs_suffix = {''};
end


ColorMap = brain_colour_maps('hot_increasing');
FigDim = [100, 100, 1000, 1500];

PCM_dir = fullfile(StartDir, 'figures', 'PCM');

%% Loading data

fprintf('Loading data\n')

% Loads which runs happened on which day to set up the CVs
load(fullfile(StartDir, 'RunsPerSes.mat'))
% to know how many ROIs we have
if surf
    load(fullfile(StartDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex')
else
    if hs_idpdt
        ROI(1).name ='V1_thres';
        ROI(2).name ='V2_thres';
        ROI(3).name ='V3_thres';
        ROI(4).name ='V4_thres';
        ROI(5).name ='V5_thres';
        ROI(6).name ='A1';
        ROI(7).name ='PT';
    else
        ROI(1).name ='A1';
        ROI(2).name ='PT';
        ROI(3).name ='V1_thres';
        ROI(4).name ='V2_thres';
        ROI(5).name ='V3_thres';
        ROI(6).name ='V4_thres';
        ROI(7).name ='V5_thres';
    end
end

for iSub = 1:NbSub
    
    fprintf(' Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    
    load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'))
    Nb_sess(iSub) = numel(SPM.Sess); %#ok<*SAGROW>
    clear SPM
    
    % Which session belings to which day (for day based CV)
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    tmp = RunPerSes(Idx).RunsPerSes;
    DayCVs{iSub} = {...
        1:tmp(1), ...
        tmp(1)+1:tmp(1)+tmp(2),...
        tmp(1)+tmp(2)+1:sum(tmp)};
    clear Idx
    
    % load data
    if surf==1 && raw ==0
        load(fullfile(Sub_dir,'results','profiles','surf','PCM','Data_PCM.mat'), 'PCM_data')
    else
        if hs_idpdt
            load(fullfile(Sub_dir,'results','rsa','vol',[SubLs(iSub).name '_data_' Save_suffix '.mat']), 'Features')
            for iROI = 1:numel(ROI)
                for ihs = 1:numel(hs_suffix)
                    PCM_data{1,iROI,ihs} = Features{iROI,ihs}; %#ok<USENS>
                end
            end
            clear Features
        else
            load(fullfile(Sub_dir,'results','PCM','vol',['Data_PCM_' Save_suffix '.mat']), 'PCM_data')
        end
    end
    
    for iToPlot = 1:numel(ToPlot)
        for iROI = 1:numel(ROI)
            for ihs = 1:numel(hs_suffix)
                Grp_PCM_data{iToPlot,iROI,iSub,ihs} = PCM_data{iToPlot,iROI,ihs};
            end
        end
    end
end



%% Stim VS Stim

if surf
    conditionVec_day=repmat((1:6)',3,1);
    
    partition_day = repmat(1:3,6,1);
    partition_day = partition_day(:);
else
    conditionVec_day=repmat((1:6),3,1);
    conditionVec_day = conditionVec_day(:);
    
    partition_day = repmat((1:3)',6,1);
end

fprintf('Running PCM\n')

for iToPlot = 1:numel(ToPlot)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
            CondNames = {...
                'ATargL','ATargR',...
                'VTargL','VTargR',...
                'TTargL','TTargR',...
                };
        else
            Stim_suffix = 'stim';
            CondNames = {...
                'A ipsi','A contra',...
                'V ipsi','V contra',...
                'T ipsi','T contra'...
                };
        end
        
        for iROI = 1:numel(ROI)
            
            fprintf('\n %s\n', ROI(iROI).name)
            
            Y = {}; condVec = {}; partVec = {};
            
            %% Preparing data
            for iSub = 1:NbSub
                
                for ihs = 1:numel(hs_suffix)
                    
                    Data = Grp_PCM_data{iToPlot,iROI,iSub,ihs};
                    
                    % Create partition and condition vector
                    if surf
                        conditionVec=repmat((1:numel(CondNames))',Nb_sess(iSub),1);
                        
                        partitionVec = repmat(1:Nb_sess(iSub),numel(CondNames),1);
                        partitionVec = partitionVec(:);
                        
                        if iSub==5
                            error('Not implemented')
                        end
                        
                    else
                        
                        if ~hs_idpdt
                            conditionVec = repmat((1:size(CondNames,2)),Nb_sess(iSub),1);
                            conditionVec = conditionVec(:);
                            
                            partitionVec = repmat((1:Nb_sess(iSub))',size(CondNames,2),1);
                            
                            if iSub==5
                                ToRemove = all([conditionVec<3 partitionVec==17],2);
                                
                                partitionVec(ToRemove) = [];
                                conditionVec(ToRemove) = [];
                            end

                        else
                            conditionVec = repmat(1:numel(CondNames)*2,Nb_sess(iSub),1);
                            conditionVec = conditionVec(:);
                            
                            partitionVec = repmat((1:Nb_sess(iSub))',numel(CondNames)*2,1);
                            
                            if iSub == 5
                                ToRemove = all([any([conditionVec<3 conditionVec==6 conditionVec==7],2) partitionVec==17],2);
                                
                                partitionVec(ToRemove) = [];
                                conditionVec(ToRemove) = [];
                            end
                            
                            if Target==1
                                conditionVec(conditionVec>6)=0;
                            else
                                conditionVec(conditionVec<7)=0;
                                conditionVec(conditionVec>6)=conditionVec(conditionVec>6)-6;
                            end
                            
                        end
                        
                    end
                    
                    if surf
                        error('Not implemented')
                    else
                        if ~hs_idpdt
                            
                            if iSub==5 %subject 06 has some condition missing for one session
                                if Target==1
                                    X_temp = Data(1:(numel(CondNames)*Nb_sess(iSub)-2) , :);
                                else
                                    X_temp = Data(1+(numel(CondNames)*Nb_sess(iSub)-2):end , :);
                                end
                            else
                                if Target==1
                                    X_temp = Data(1:numel(CondNames)*Nb_sess(iSub) , :);
                                else
                                    X_temp = Data(1+numel(CondNames)*Nb_sess(iSub):end , :);
                                end
                            end
                            
                        else
                            % remove condition of no interests
                            X_temp = Data; clear Data
                            X_temp(conditionVec==0,:)=[];
                            partitionVec(conditionVec==0,:)=[];
                            conditionVec(conditionVec==0,:)=[];
                            
                        end
                    end
                    
                    
                    % remove nans
                    if any(all(isnan(X_temp),2))
                        warning('We have some NaNs issue.')
                        partitionVec(all(isnan(X_temp),2))=[];
                        conditionVec(all(isnan(X_temp),2))=[];
                        X_temp(all(isnan(X_temp),2),:) = [];
                    end
                    X_temp(:,any(isnan(X_temp))) = [];
                    
                    
                    % check that we have the same number of conditions in each
                    % partition
                    A = tabulate(partitionVec);
                    A = A(:,1:2);
                    if numel(unique(A(:,2)))>1
                        warning('We have different numbers of conditions in at least one partition.')
                        Sess2Remove = find(A(:,2)<numel(unique(conditionVec)));
                        conditionVec(ismember(partitionVec,Sess2Remove)) = [];
                        X_temp(ismember(partitionVec,Sess2Remove),:) = [];
                        partitionVec(ismember(partitionVec,Sess2Remove)) = [];
                        Sess2Remove = [];
                    end
                    
                    if any([numel(conditionVec) numel(partitionVec)]~=size(X_temp,1))
                        error('Data matrix or condition or partition vector might be off.')
                    end
                    
                    
                    % Stores each subject
                    Y{iSub,ihs} = X_temp;
                    condVec{iSub} = conditionVec;
                    partVec{iSub} = partitionVec;
                    
                end
                
            end
            
            
            %% plot
            opt.FigName = sprintf('-%s-Data-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), Stim_suffix, ...
                Beta_suffix, ToPlot{iToPlot});
            
            close all
            
            for iSub = 1:NbSub

                for ihs = 1:numel(hs_suffix)
                    
                    %%
                    fig_h = figure('name', [SubLs(iSub).name '-' hs_suffix{ihs} '-' opt.FigName], 'Position', FigDim, 'Color', [1 1 1]);
                    
                    colormap(seismic(1000))
                    
                    Subplot = 1;
                    
                    subplot(1,2,Subplot)
                    %                 Data = Y{iSub};
                    %                 for i=1:max(partVec{iSub})
                    %                     Row_2_sort = find(all([condVec{iSub}==1 partVec{iSub}==i],2));
                    %                     [~,I] = sort(Data(Row_2_sort,:)); %#ok<FNDSB>
                    %                     Data(partVec{iSub}==i,:) = Data(partVec{iSub}==i,I);
                    %                 end
                    %                 imagesc(imgaussfilt(Data,[.001 100]), [-.5 .5])
                    %                 hold on
                    %                 ax = axis;
                    %                 axis_cdt_limit(partVec{iSub},DayCVs{iSub},ax)
                    %                 title('Y sorted session wise as f(A_{ipsi})')
                    
                    Data = Y{iSub,ihs};
                    [~,I] = sort(mean(Data));
                    Data = Data(:,I);
                    imagesc(imgaussfilt(Data,[.001 50]), [-.5 .5])
                    hold on
                    ax = axis;
                    axis_cdt_limit(partVec{iSub},DayCVs{iSub},ax)
                    title('Y as f(mean(act))')
                    
                    Subplot = Subplot+1;
                    
                    subplot(1,2,Subplot)
                    YY = Data*Data';
                    MAX = min(abs([max(YY(:)) min(YY(:))]));
                    imagesc(YY, [MAX*-1 MAX])
                    hold on
                    ax = axis;
                    axis_cdt_limit(partVec{iSub},DayCVs{iSub},ax)
                    title('Y*Y^T')
                    
                    Subplot = Subplot+1;
                    
                    mtit(fig_h.Name, 'fontsize', 12, 'xoff',0,'yoff',.05)
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', [fig_h.Name, '.tif'] ), '-dtiff')
                    
                    
                    %%
                    fig_h = figure('name', [SubLs(iSub).name '-' hs_suffix{ihs} '--session-sorted--' opt.FigName], 'Position', FigDim, 'Color', [1 1 1]);
                    
                    colormap(seismic(1000))
                    
                    subplot(1,2,1)
                    
                    Data = [];
                    for i=1:max(partVec{iSub})
                        tmp = Y{iSub,ihs}(partVec{iSub}==i,:);
                        Data = [Data;tmp];
                    end
                    clear tmp
                    
                    [~,I] = sort(mean(Data));
                    Data = Data(:,I);
                    imagesc(imgaussfilt(Data,[.001 50]), [-.5 .5])
                    hold on
                    ax = axis;
                    axis_cdt_limit_2(partVec{iSub},ax)
                    title('Y as f(mean(act))')
                    
                    subplot(1,2,2)
                    YY = Data*Data';
                    MAX = max(abs([max(YY(:)) min(YY(:))]))/5;
                    imagesc(YY, [MAX*-1 MAX])
                    hold on
                    ax = axis;
                    axis_cdt_limit_2(partVec{iSub},ax)
                    title('Y*Y^T')
                    
                    mtit(fig_h.Name, 'fontsize', 12, 'xoff',0,'yoff',.05)
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', [fig_h.Name, '.tif'] ), '-dtiff')
                    
                end
                
            end
            
        end
        
    end
end
end


function axis_cdt_limit(partVec,Day_limits,ax)
Limits = (1:max(partVec):max(partVec)^2)-.5;
colorbar
set(gca,'Xtick',[],'Ytick',Limits, 'Yticklabel', [], ...
    'tickdir', 'out')
for i=1:numel(Limits)
    plot([ax(1) ax(2)],[Limits(i) Limits(i)],'-k','linewidth', 2)
    
    for iDay = 1:numel(Day_limits)
        plot([ax(1) ax(2)],[Limits(i)+Day_limits{iDay}(end) Limits(i)+Day_limits{iDay}(end)],'-k')
    end
    
end

end

function axis_cdt_limit_2(partVec,ax)
Limits = (1:6:(max(partVec)*6))-.5;
colorbar
set(gca,'Xtick',[],'Ytick',Limits, 'Yticklabel', [], ...
    'tickdir', 'out')
for i=1:numel(Limits)
    plot([ax(1) ax(2)],[Limits(i) Limits(i)],'-k','linewidth', 1)
end

end
