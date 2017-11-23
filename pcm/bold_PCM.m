clc; clear; close all

StartDir = fullfile(pwd, '..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')

surf = 0; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
Plot = 1; % plot figures
do_null_free_only = 0;
do_models_only = 0;

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

MaxIteration = 50000;

if surf
    %     ToPlot={'Cst','Lin','Quad'};
    ToPlot={'Cst'};
    Output_dir = 'surf';
else
    ToPlot={'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol';
    if raw
        Save_suffix = 'beta-raw';
    else
        Save_suffix = 'beta-wht'; %#ok<*UNRCH>
    end
end

if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end


ColorMap = brain_colour_maps('hot_increasing');
FigDim = [100, 100, 1000, 1500];

PCM_dir = fullfile(StartDir, 'figures', 'PCM');
mkdir(PCM_dir)
mkdir(PCM_dir, 'Cdt');

Save_dir = fullfile(StartDir, 'results', 'PCM', Output_dir);
mkdir(Save_dir)



if ~do_null_free_only
    %% Set the different pattern components
    [Components, h] = Set_PCM_components_RDM(1, FigDim);
    if ~isempty(h)
        print(h(1), fullfile(PCM_dir, 'Cdt', 'Pattern_components_RDM.tif'), '-dtiff');
        print(h(2), fullfile(PCM_dir, 'Cdt', 'Pattern_components_G_matrices.tif'), '-dtiff');
    end
    
%     [Components, h] = Set_PCM_components_Feature(1, FigDim);
%     if ~isempty(h)
%         print(h(1), fullfile(PCM_dir, 'PCM_features.tif'), '-dtiff');
%         print(h(2), fullfile(PCM_dir, 'PCM_G_matrix.tif'), '-dtiff');
%         print(h(3), fullfile(PCM_dir, 'PCM_RDMs.tif'), '-dtiff');
%     end
    %% Display the different models
    [Models_A, Models_V, h] = Set_PCM_models(Components, 1, FigDim);
    if ~isempty(h)
        print(h(1), fullfile(PCM_dir, 'Cdt', 'Models_for_auditory_ROIs.tif'), '-dtiff');
        print(h(2), fullfile(PCM_dir, 'Cdt', 'Models_for_visual_ROIs.tif'), '-dtiff');
    end
end

%% Loading data

fprintf('Loading data\n')

% Loads which runs happened on which day to set up the CVs
load(fullfile(StartDir, 'RunsPerSes.mat'))
% to know how many ROIs we have
if surf
    load(fullfile(StartDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex')
else
    ROI(1).name ='A1';
    ROI(2).name ='PT';
    ROI(3).name ='V1_thres';
    ROI(4).name ='V2_thres';
    ROI(5).name ='V3_thres';
    ROI(6).name ='V4_thres';
    ROI(7).name ='V5_thres';
end

for iSub = 1:NbSub
    
    fprintf(' Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    
    load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'))
    Nb_sess(iSub) = numel(SPM.Sess); %#ok<*SAGROW>
    clear SPM
    
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
        load(fullfile(Sub_dir,'results','PCM','vol',['Data_PCM_' Save_suffix '.mat']), 'PCM_data', 'ROIs')
    end
    
    for iToPlot = 1:numel(ToPlot)
        for iROI = 1:numel(ROI)
            Grp_PCM_data{iToPlot,iROI,iSub} = PCM_data{iToPlot,iROI};
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
        
        AllTgroup=cell(numel(ROI),1);
        Alltheta=cell(numel(ROI),1);
        AllTcross=cell(numel(ROI),1);
        AllthetaCr=cell(numel(ROI),1);
        
        for iROI = 3 %1:numel(ROI)
            
            fprintf('\n %s\n', ROI(iROI).name)
            
            Y = {}; condVec = {}; partVec = {};
            
            %% Preparing data
            for iSub = 1:size(Grp_PCM_data,3)
                
                Data = Grp_PCM_data{iToPlot,iROI,iSub};
                
                if iSub==5
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
                
                
                if surf
                    if iSub==5
                        error('Not implemented')
                    else
                        conditionVec=repmat((1:numel(CondNames))',Nb_sess(iSub),1);
                        
                        partitionVec = repmat(1:Nb_sess(iSub),numel(CondNames),1);
                        partitionVec = partitionVec(:);
                    end
                else
                    if iSub==5
                        conditionVec = repmat((1:size(CondNames,2)),Nb_sess(iSub),1);
                        conditionVec = conditionVec(:);
                        
                        partitionVec = repmat((1:Nb_sess(iSub))',size(CondNames,2),1);
                        
                        ToRemove = all([conditionVec<3 partitionVec==17],2);
                        
                        partitionVec(ToRemove) = [];
                        conditionVec(ToRemove) = [];
                    else
                        conditionVec = repmat((1:size(CondNames,2)),Nb_sess(iSub),1);
                        conditionVec = conditionVec(:);
                        
                        partitionVec = repmat((1:Nb_sess(iSub))',size(CondNames,2),1);
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
                Y{iSub} = X_temp;
                condVec{iSub} = conditionVec;
                partVec{iSub} = partitionVec;
                
            end
            
            
            %% Now build the models
            if ~do_null_free_only
                if iROI<3
                    Models = Models_A;
                else
                    Models = Models_V;
                end
            end
            
            M = {};
            
            colors={'b'};
            
            if ~do_models_only
                % null model
                M{1}.type       = 'component';
                M{1}.numGparams = 1;
                M{1}.Gc         = nearestSPD(zeros(numel(CondNames)));
                M{1}.name       = 'null';
                M{1}.fitAlgorithm = 'minimize';
            end
            
            
            if ~do_null_free_only
                % add each model
                for iMod=1:numel(Models)
                    
                    M{end+1}.type       = 'component';
                    
                    M{end}.numGparams = numel(Models(iMod).Cpts);
                    
                    M{end}.Gc         = cat(3,Components(Models(iMod).Cpts).G);
                    
                    tmp = strrep(num2str(Models(iMod).Cpts),'  ', ' ');
                    tmp = strrep(tmp,'  ', ' ');
                    M{end}.name       = strrep(tmp,' ', '+'); clear tmp
                    
                    M{end}.fitAlgorithm = 'minimize';
                    
                    colors{end+1}='b';
                    
                end
            end
            
            if ~do_models_only
                % Free model as Noise ceiling
                M{end+1}.type       = 'freechol';
                M{end}.numCond    = numel(CondNames);
                M{end}.name       = 'noiseceiling';
                M{end}           = pcm_prepFreeModel(M{end});
                M{end}.fitAlgorithm = 'minimize';
            end
            
            
            %% 1. Get the crossvalidated G-matrix for each data set
            G_hat = [];
            
            for iSub=1:length(Y)
                G_hat(:,:,iSub)=pcm_estGCrossval(Y{iSub},partVec{iSub},condVec{iSub});
            end;
            
            Gm = mean(G_hat,3); % Mean estimate
            H = eye(numel(CondNames))-ones(numel(CondNames))/numel(CondNames);
            
            
            %% 2. average G-matrix using an MDS plot
            C= pcm_indicatorMatrix('allpairs',(1:numel(CondNames))');
            [COORD,l]=pcm_classicalMDS(Gm,'contrast',C);
            
            
            %% Plot
            figure('name', sprintf('PCM - %s - %s - %s - %s', Stim_suffix, Beta_suffix, ROI(iROI).name, ToPlot{iToPlot}),...
                'Position', FigDim, 'Color', [1 1 1]);
            
            % G matrix
            subplot(3,4,1);
            colormap(ColorMap);
            
            imagesc(H*Gm*H');
            
            axis on
            set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                'ytick', 1:6,'yticklabel', CondNames, ...
                'ticklength', [0.01 0], 'fontsize', 4)
            box off
            axis square
            t=title('Crossvalidated G matrix');
            set(t, 'fontsize', 10);
            
            % MDS
            subplot(3,4,3)
            
            
            plot(COORD(:,1),COORD(:,2),'o');
            %             axis equal
            axis square
            grid on
            t=title('G matrix via MDS');
            set(t, 'fontsize', 10);
            
            
            %% Run the PCM
            % Treat the run effect as random or fixed?
            % We are using a fixed run effect here, as we are not interested in the
            % activity relative the the baseline (rest) - so as in RSA, we simply
            % subtract out the mean patttern across all conditions.
            runEffect  = 'fixed';
            
            % Fit the models on the group level
            [Tgroup,theta] = pcm_fitModelGroup(Y,M,partVec,condVec,'runEffect',runEffect,'fitScale',1);
            
            % Fit the models through cross-subject crossvalidation
            [Tcross,thetaCr] = pcm_fitModelGroupCrossval(Y,M,partVec,condVec,'runEffect',runEffect,'groupFit',...
                theta,'fitScale',1,'MaxIteration',MaxIteration);
            
            
            %% Plot
            if Plot && ~do_null_free_only && ~do_models_only
                
                % Provide a plot of the crossvalidated likelihoods
                subplot(3,4,5:12);
                hold on
                
                T = pcm_plotModelLikelihood(Tcross,M,'upperceil',Tgroup.likelihood(:,end), 'colors', colors);

                % print subjects
                binWidth = max(max(T.likelihood_norm(:,2:end-1))-min(T.likelihood_norm(:,2:end-1)));
                
                for iM=2:numel(M)-1
                    h = plotSpread(T.likelihood_norm(:,iM), 'distributionIdx', ones(size(T.likelihood_norm(:,iM))), ...
                        'distributionMarkers',{'o'},'distributionColors',{'w'}, ...
                        'xValues', iM-1, 'binWidth', binWidth/100, 'spreadWidth', .8);
                    set(h{1}, 'MarkerSize', 5, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
                    labels{iM-1} = M{iM}.name;
                end
                ax=axis;
                
                MIN = min(min(T.likelihood_norm(:,2:end-1)));
                MAX = max(max(T.likelihood_norm(:,2:end-1)));
                
                if MIN<0
                    ax=axis;
                    MIN = ceil(abs(MIN));
                    axis([ax(1) ax(2) MIN*-1 MAX])
                end

                set(gca,'XTick',1:numel(M)-2);
                set(gca,'XTickLabel',labels);
                set(gca,'fontsize', 8)

                mtit(sprintf('PCM - %s - %s - %s - %s', Stim_suffix, Beta_suffix, ROI(iROI).name, ToPlot{iToPlot}), 'fontsize', 12, 'xoff',0,'yoff',.035)
                
            end
            
            print(gcf, fullfile(PCM_dir, 'Cdt', sprintf('PCM_%s_%s_%s_%s.tif', Stim_suffix, Beta_suffix, ROI(iROI).name, ToPlot{iToPlot})), '-dtiff')
            
            %% Save
            if do_null_free_only
                save(fullfile(Save_dir, sprintf('PCM_null_free_%s_%s_%s_%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, ToPlot{iToPlot})), ...
                    'Tgroup', 'theta', 'Tcross', 'thetaCr', 'partVec', 'condVec', 'G_hat', 'M')
            else
                save(fullfile(Save_dir, sprintf('PCM_%s_%s_%s_%s_%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, ...
                    ToPlot{iToPlot}, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                    'Tgroup', 'theta', 'Tcross', 'thetaCr', 'partVec', 'condVec', 'G_hat', 'M', 'Models_A', 'Models_V',...
                    'Components')
            end
            
            
        end
        
        %% save
        
    end
end

