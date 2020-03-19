function MVPA_surf_grp_avg

clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

Get_dependencies('/home/rxg243/Dropbox')


ResultsDir = fullfile(StartDir, 'results', 'SVM');
[~,~,~] = mkdir(ResultsDir);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

% Options for the SVM
[opt, ~] = get_mvpa_options();


DesMat = set_design_mat_lam_GLM(NbLayers);


SubLs = dir('sub*');
NbSub = numel(SubLs);


for Norm = 6
    
    clear ROIs SVM
    
    [opt] = ChooseNorm(Norm, opt);
    
    SaveSufix = CreateSaveSuffix(opt, [], NbLayers, 'surf');
    
    % ROI
    ROIs(1) = struct('name', 'V1');
    ROIs(end+1) = struct('name', 'V2');
    ROIs(end+1) = struct('name', 'V3');
    ROIs(end+1) = struct('name', 'V4');
    ROIs(end+1) = struct('name', 'V5');
    
    ROIs(end+1) = struct('name', 'A1');
    ROIs(end+1) = struct('name', 'PT');
    
    % Analysis
    SVM(1) = struct('name', 'A Ipsi VS Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V Ipsi VS Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'T Ipsi VS Contra', 'ROI', 1:length(ROIs));
    
    SVM(end+1) = struct('name', 'A VS V Ipsi', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'A VS T Ipsi', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V VS T Ipsi', 'ROI', 1:length(ROIs));
    
    SVM(end+1) = struct('name', 'A VS V Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'A VS T Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V VS T Contra', 'ROI', 1:length(ROIs));
    
    
    for i=1:numel(SVM)
        SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI).name}); %#ok<*AGROW>
    end
    
    %% Gets data for each subject
    for iSubj = 1:NbSub
        fprintf('\n\nProcessing %s', SubLs(iSubj).name)
        
        SubDir = fullfile(StartDir, SubLs(iSubj).name);
        SaveDir = fullfile(SubDir, 'results', 'SVM');
        
        for iSVM = 1:numel(SVM)
            fprintf('\n Running SVM:  %s', SVM(iSVM).name)
            
            for iROI=1:numel(ROIs)
                
                File2Load = fullfile(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_no-pool-ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]));
                
                if exist(File2Load,'file')
                    
                    load(File2Load, 'Results', 'Class_Acc', 'opt')
                    
                    for ihs=1:2
                        
                        SVM(iSVM).ROI(iROI).grp(iSubj,ihs) = Class_Acc.TotAcc(ihs);
                        if isempty(Class_Acc.TotAccLayers{ihs})
                            SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj,ihs) = nan(NbLayers);
                        else
                            SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj,ihs) = Class_Acc.TotAccLayers{ihs};
                        end
                        
                        % Extract results
                        CV = Results(ihs).session(end).rand.perm.CV;
                        NbCV = size(CV,1); %#ok<*NODEF>
                        
                        for iCV=1:NbCV
                            
                            % For the whole ROI
                            SVM(iSVM).ROI(iROI).DATA{iSubj}(iCV,ihs) = CV(iCV).acc;
                            
                            if isempty(CV(iCV).layers.results{1})
                                SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(:,iCV,ihs) = nan(1,NbLayers);
                            else
                            for iLayer = 1:NbLayers
                                label = CV(iCV).layers.results{1}{iLayer}.label;
                                pred = CV(iCV).layers.results{1}{iLayer}.pred(:,iLayer);
                                
                                SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(iLayer,iCV,ihs) = mean(pred==label);
                                clear pred label
                            end
                            end
                            
                        end
                    end
                    
                else
                    warning('\nThe file %s was not found.', File2Load)
                    
                    SVM(iSVM).ROI(iROI).grp(iSubj,1:NbLayers) = nan(1, NbLayers, 2);
                    SVM(iSVM).ROI(iROI).DATA{iSubj} = [];
                    SVM(iSVM).ROI(iROI).layers.DATA{iSubj} = [];
                    
                end
                
                clear Results Class_Acc
                
            end
            
        end
    end
    
    %% Averages over subjects
    for iSVM = 1:numel(SVM)
        for iROI=1:numel(ROIs)
            
            SVM(iSVM).ROI(iROI).MEAN = nanmean(SVM(iSVM).ROI(iROI).grp);
            SVM(iSVM).ROI(iROI).STD = nanstd(SVM(iSVM).ROI(iROI).grp);
            SVM(iSVM).ROI(iROI).SEM = nansem(SVM(iSVM).ROI(iROI).grp);
            
            for ihs = 1:2
                for iSubj=1:numel(SVM(iSVM).ROI(iROI).layers.DATA)
                    tmp(iSubj,1:NbLayers) = mean(SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(:,:,ihs),2);
                end
                SVM(iSVM).ROI(iROI).layers.MEAN(ihs,:) = mean(tmp);
                SVM(iSVM).ROI(iROI).layers.STD(ihs,:) = std(tmp);
                SVM(iSVM).ROI(iROI).layers.SEM(ihs,:) = nansem(tmp);
            end
            
        end
    end
    
    %% Betas from profile fits
    fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS')
    
    for iSVM = 1:numel(SVM)
        fprintf('\n Running SVM:  %s', SVM(iSVM).name)
        
        for iROI=1:numel(ROIs)
            
            %% Actually compute betas
            for iSub = 1:NbSub
                
                for ihs = 1:2
                    
                    Blocks = SVM(iSVM).ROI(iROI).layers.DATA{iSub}(:,:,ihs);
                    
                    if ~all(isnan(Blocks(:))) || ~isempty(Blocks)
                        
                        Y = Blocks-.5;
                        [B] = laminar_glm(DesMat, Y);
                        
                        SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,iSub,ihs)=B;
                        
                        clear Y B
                        
                    else
                        SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,iSub)=nan(size(DesMat,2),1);
                        
                    end
                    
                end
                
            end
            
            %% Group stat on betas
            for ihs = 1:2
                tmp = SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,:,ihs);
                SVM(iSVM).ROI(iROI).layers.Beta.MEAN(:,ihs)=nanmean(tmp, 2);
                SVM(iSVM).ROI(iROI).layers.Beta.Beta.STD(:,ihs)=nanstd(tmp, 2);
                SVM(iSVM).ROI(iROI).layers.Beta.Beta.SEM(:,ihs)=nansem(tmp, 2);
                
                % T-Test
                [~,P] = ttest(tmp');
                SVM(iSVM).ROI(iROI).Beta.P(ihs,:)=P;
                
                clear tmp P
            end
            

            
        end
    end
    
    %% Saves
    fprintf('\n\nSaving\n')
    
    for iSVM = 1:numel(SVM)
        for iROI=1:numel(ROIs)
            Results = SVM(iSVM).ROI(iROI);
            save( fullfile(ResultsDir, strcat('Grp_', SVM(iSVM).ROI(iROI).name, '_', strrep(SVM(iSVM).name,' ','-'),...
                '_NoPoolQuadGLM',  SaveSufix)), 'Results')
        end
    end
    
    save( fullfile(ResultsDir, strcat('GrpNoPoolQuadGLM', SaveSufix)) )
    
    cd(StartDir)
    
end


end