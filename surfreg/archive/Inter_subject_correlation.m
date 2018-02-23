%%
clear
clc

StartFolder = fullfile(pwd, '..', '..');
cd(StartFolder)
addpath(genpath(fullfile(StartFolder, 'SubFun')));

SubjToInclude = true(13,1);
SubjToInclude([4 11],1) = false;

NbLayers = 6;

Conditions_Names = {...
    'A-Stim_Auditory-Attention', ...
    'V-Stim_Auditory-Attention', ...
    'AV-Stim_Auditory-Attention', ...
    'A-Stim_Visual-Attention', ...
    'V-Stim_Visual-Attention', ...
    'AV-Stim_Visual-Attention'};

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers,1) DesMat'];
DesMat = spm_orth(DesMat);

% Color map
X = 0:0.001:1;
R = 1 - 0.392*(1 + erf((X - 0.869)/ 0.255));
G = 1.021 - 0.456*(1 + erf((X - 0.527)/ 0.376));
B = 1 - 0.493*(1 + erf((X - 0.272)/ 0.309));
ColorMap = [R' G' B'];
ColorMap = flipud(ColorMap);


FigDim = [100, 100, 1000, 1500];
Visibility = 'on';

DataFolder = fullfile('/home/rxg243/Documents/GrpAverage/BoldAvg');

figure('name','Legend')
colormap(ColorMap);
imagesc(repmat([1:-.01:0]', [1,200]), [0 1])
set(gca,'xtick',[],'ytick',linspace(1,100,9),'yticklabel',linspace(1,0,9));
print(gcf, fullfile(DataFolder,'Cross_subjects_correlation_scale.tif'), '-dtiff')


for ihs = 1:2
    if ihs ==1
        HS = 'L'; hs = 'l';
    else
        HS = 'R'; hs = 'r';
    end
    
    cd('/home/rxg243/Documents/GrpAverage/ROI')
    ROI_name = {'A1' 'PT' 'V1' 'V2-3'};
    for iROI = 1:numel(ROI_name)
        [~,~,ROI_Mapping{ihs}(iROI,:)] = read_vtk([ROI_name{iROI} '_' hs 'h_thres.vtk'], 0, 1); %#ok<*SAGROW>
    end
    
    cd(fullfile(DataFolder, [HS 'H']))
    
    %%
    for iCond = 1:6
        
        fprintf('\n Reading data\n')
        
        for iLayer = 1:NbLayers
            
            VTK_file = dir(['GrpSurf_' Conditions_Names{iCond} '_' num2str(iLayer) '-Layer_' hs 'h.vtk']);
            
            disp(VTK_file.name)
            
            [~,~,Mapping] = read_vtk(VTK_file.name, 12, 1);
            
            AllLayers{ihs}(:,:,iLayer,iCond) = Mapping;
            
        end
        
    end
    
end

%%
ROI_mapping_both_hs = cat(2, ROI_Mapping{1},ROI_Mapping{2});
AllLayers_both_hs = cat(2,AllLayers{1},AllLayers{2});

%%
close all

Cond = {[1;4], [2;5], [3;6]};
CondName = {'A-Stim', 'V-Stim', 'AV-Stim'};

ToPlot = {'Cst', 'Lin', 'Quad'};

H(1) = figure('name', 'Inter sujbect correlation - Cst', ...
    'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility);
H(2) = figure('name', 'Inter sujbect correlation - Lin', ...
    'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility);
H(3) = figure('name', 'Inter sujbect correlation - Quad', ...
    'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility);

for iCond = 1:numel(Cond)
    
    CondLayers = ...
        (sum(AllLayers_both_hs(SubjToInclude,:,:,Cond{iCond}(1,:)),4) ...
        + sum(AllLayers_both_hs(SubjToInclude,:,:,Cond{iCond}(2,:)),4) )/ 2;
    
    IsZero = CondLayers==0;
    IsZero = any(IsZero,3);
    fprintf('\n')
    tabulate(sum(IsZero))
    
    Betas = zeros(sum(SubjToInclude), size(AllLayers_both_hs,2));
    
    fprintf('\nGLM on vertices with %i subjects', sum(SubjToInclude))
    
    VertOfInt = find(sum(IsZero)==0);
    
    Y = [];
    parfor iVert = 1:numel(VertOfInt)
        Subj2Exclu = find(~IsZero(:,VertOfInt(iVert)));
        Y(:,iVert,:) = CondLayers(Subj2Exclu,VertOfInt(iVert),:);
    end
    
    Y = shiftdim(Y,2);
    Y = reshape(Y, [size(Y,1)*size(Y,2),size(Y,3)] );
    
    X = [];
    for iSubj=1:(sum(SubjToInclude))
        X((1:6)+6*(iSubj-1),(1:size(DesMat,2))+size(DesMat,2)*(iSubj-1)) = DesMat;
    end
    
    B = pinv(X)*Y;

    for i = 1:3
        figure(H(i))
        
        Betas_tmp = B(i:3:size(X,2),:);
        Betas(:,VertOfInt) = Betas_tmp;
        
        for iROI = 1:numel(ROI_name)
            tmp =  Betas(:,logical(ROI_mapping_both_hs(iROI,:)))';
            rho = corr(tmp);
            tmp = triu(rho,1); tmp = tmp(:); tmp(tmp==0)=[];
            RHO_ROI(:,iROI,iCond,i) = tmp;

            subplot(numel(ROI_name),numel(Cond),iCond+3*(iROI-1))
            colormap(ColorMap);
            imagesc(rho, [0 1])
            
            set(gca,'tickdir', 'out', 'xtick', [],'xticklabel',  [], ...
                'ytick', [],'yticklabel', [], ...
                'ticklength', [0.01 0], 'fontsize', 10)
            
            axis square
            
            if iCond==1
                t=ylabel(ROI_name{iROI});
                set(t,'fontsize',10)
            end
            
            if iROI==1
                title(CondName{iCond});
            end
            
            clear tmp
        end
    end

    fprintf('\n');
    
end

for i = 1:3
    figure(H(i))
    mtit(['Inter subject vertex wise correlations - ' ToPlot{i}], 'fontsize', 14, 'xoff',0,'yoff',.035)
    print(gcf, fullfile(DataFolder,['Cross_subjects_correlation_' ToPlot{i} '.tif']), '-dtiff')
end

%%
close all

CondName = {'A-Stim', 'V-Stim', 'AV-Stim'};

ToPlot = {'Cst', 'Lin', 'Quad'};

H = figure('name', 'Inter ROI correlation', ...
    'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility);


for iCond = 1:numel(Cond)
    
    for i = 1:3

        tmp =  RHO_ROI(:,:,iCond,i);
        rho = corr(tmp);
        tmp = triu(rho,1); tmp = tmp(:); tmp(tmp==0)=[];
        
        subplot(3,numel(Cond),iCond+3*(i-1))
        colormap(ColorMap);
        imagesc(rho, [0 1])
        
        set(gca,'tickdir', 'out', 'xtick', 1:4,'xticklabel', ROI_name, ...
            'ytick', 1:4,'yticklabel', ROI_name, ...
            'ticklength', [0.01 0], 'fontsize', 10)
        
        axis square
        
        if iCond==1
            t=ylabel(ToPlot{i});
            set(t,'fontsize',10)
        end
        
        if i==1
            title(CondName{iCond});
        end
        
        clear tmp
    end
end

mtit('Inter ROI correlations', 'fontsize', 14, 'xoff',0,'yoff',.035)
print(gcf, fullfile(DataFolder,'Cross_ROI_correlation_.tif'), '-dtiff')


%%
close all

CondName = {'A', 'V', 'AV'};

ToPlot = {'Cst', 'Lin', 'Quad'};

H = figure('name', 'Inter Cond correlation', ...
    'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility);

for iROI = 1:numel(ROI_name)
    
    for i = 1:3

        tmp =  squeeze(RHO_ROI(:,iROI,:,i));
        rho = corr(tmp);
        tmp = triu(rho,1); tmp = tmp(:); tmp(tmp==0)=[];
        
        subplot(3,numel(ROI_name),iROI+4*(i-1))
        colormap(ColorMap);
        imagesc(rho, [0 1])
        
        set(gca,'tickdir', 'out', 'xtick', 1:3,'xticklabel', CondName, ...
            'ytick', 1:3,'yticklabel', CondName, ...
            'ticklength', [0.01 0], 'fontsize', 10)
        
        axis square
        
        if iROI==1
            t=ylabel(ToPlot{i});
            set(t,'fontsize',10)
        end
        
        if i==1
            title(ROI_name{iROI});
        end
        
        clear tmp
    end
end

mtit('Inter condition correlations', 'fontsize', 14, 'xoff',0,'yoff',.035)
print(gcf, fullfile(DataFolder,'Cross_cond_correlation_.tif'), '-dtiff')