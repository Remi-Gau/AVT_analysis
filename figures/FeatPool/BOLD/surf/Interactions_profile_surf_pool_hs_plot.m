function Interactions_profile_surf_pool_hs_plot
clc; clear;

StartDir = fullfile(pwd, '..','..','..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')


ResultsDir = fullfile(StartDir, 'results', 'profiles','surf');
FigureFolder = fullfile(StartDir, 'figures', 'profiles','surf');


SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers=6;

for WithPerm = 1
    
    sets = {};
    for iSub=1:NbSub
        sets{iSub} = [-1 1];
    end
    [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
    ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
    
    if ~WithPerm
        ToPermute = [];
    end
    
    
    load(fullfile(ResultsDir, strcat('ResultsSurfPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
    Stimuli_data = AllSubjects_Data;
    
    load(fullfile(ResultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
    Target_data = AllSubjects_Data;
    
    
    
    NbROI = length(Stimuli_data);
    ROI_order = [1 NbROI 2:NbROI-1];
    
    ROI_idx = 1;
    for iROI = ROI_order
        ToPlot.ROIs_name{ROI_idx} = Stimuli_data(iROI).name;
        ROI_idx = ROI_idx + 1;
    end
    
    
    %%
    close all
    
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.ToPermute = ToPermute;
    
    fig = figure('Name', 'Interactions', 'Position', [100, 100, 1500, 1000], 'Color', [1 1 1], 'Visible', ToPlot.Visible);
    
    set(gca,'units','centimeters')
    pos = get(gca,'Position');
    ti = get(gca,'TightInset');
    
    set(fig, 'PaperUnits','centimeters');
    set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    set(fig, 'PaperPositionMode', 'manual');
    set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    
    set(fig, 'Visible', ToPlot.Visible)
    
    
    %% Contra-Ipsi
    ToPlot.Legend = {'(Contra-Ipsi)_A', '(Contra-Ipsi)_V','(Contra-Ipsi)_T'};
    ToPlot.SubplotNumber = 1:3;
    Data_stim = cat(1,Stimuli_data(:).Contra_VS_Ipsi);
    Data_target = cat(1,Target_data(:).Contra_VS_Ipsi);
    ToPlot = GetData(ToPlot,Data_stim,Data_target,ROI_order);
    
    Plot_interaction(ToPlot)
    
    
    %% Contrast between sensory modalities Ispi
    ToPlot.Legend = {'(Audio-Visual)_{ipsi}', '(Audio-Tactile)_{ipsi}','(Visual-Tactile)_{ipsi}'};
    ToPlot.SubplotNumber = 4:6;
    Data_stim = cat(1,Stimuli_data(:).ContSensModIpsi);
    Data_target = cat(1,Target_data(:).ContSensModIpsi);
    ToPlot = GetData(ToPlot,Data_stim,Data_target,ROI_order);
    
    Plot_interaction(ToPlot)
    
    %% Contrast between sensory modalities Contra
    ToPlot.Legend = {'(Audio-Visual)_{contra}', '(Audio-Tactile)_{contra}','(Visual-Tactile)_{contra}'};
    ToPlot.SubplotNumber = 7:9;
    Data_stim = cat(1,Stimuli_data(:).ContSensModContra);
    Data_target = cat(1,Target_data(:).ContSensModContra);
    ToPlot = GetData(ToPlot,Data_stim,Data_target,ROI_order);
    
    Plot_interaction(ToPlot)
    
    %%
    mtit('Interactions','xoff', 0, 'yoff', +0.05, 'fontsize', 12)
    
    print(fig, fullfile(ToPlot.FigureFolder, 'All_ROIs_interactions.tif'), '-dtiff')
end
cd(StartDir)

end

function ToPlot = GetData(ToPlot,Data_stim,Data_target,ROI_order)
ROI_idx = 1;
for iROI = ROI_order
    ToPlot.ROI.grp(1,:,:,ROI_idx) = Data_stim(iROI).whole_roi_grp;
    ToPlot.ROI.grp(2,:,:,ROI_idx) = Data_target(iROI).whole_roi_grp;
    ROI_idx = ROI_idx + 1;
end
end

function Plot_interaction(ToPlot)

Xpos = [1 3 7:2:15];

Alpha = 0.05;

for iCdt = 1:size(ToPlot.ROI.grp,3)
    
    subplot(3,3,ToPlot.SubplotNumber(iCdt))
    hold on
    
    for iROI=1:size(ToPlot.ROI.grp,4)
        A = ToPlot.ROI.grp(:,:,iCdt,iROI);
        plot(repmat([Xpos(iROI)-.25;Xpos(iROI)+0.25],1,size(A,2)),A, '.-k')
    end
    
    plot([-20 20], [0 0], '--k')
    
    axis tight
    set(gca, 'tickdir', 'out', 'xtick', Xpos,'xticklabel',ToPlot.ROIs_name, ...
        'ticklength', [0.01 0.01], 'fontsize', 10)
    
    t=title(ToPlot.Legend{iCdt});
    set(t,'fontsize',10);
    
    t=ylabel(sprintf('Param. est. [a u]'));
    set(t,'fontsize',10);
    
    ax = axis;
    axis([0.5 15.5 ax(3) ax(4)+ax(4)*.25])
    
    
    tmp = squeeze(ToPlot.ROI.grp(1,:,iCdt,:)-ToPlot.ROI.grp(2,:,iCdt,:));
    
    for iPerm = 1:size(ToPlot.ToPermute,1)
        tmp2 = ToPlot.ToPermute(iPerm,:);
        tmp2 = repmat(tmp2',1,size(tmp,2));
        Perms(iPerm,:) = mean(tmp.*tmp2); %#ok<*SAGROW>
    end
    
    P = sum( ...
        abs( Perms ) > ...
        repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
        / size(Perms,1) ;
    
    for iP = 1:numel(P)
        Sig = [];
        if P(iP)<0.001
            Sig = sprintf('p<0.001 ');
        else
            Sig = sprintf('p=%.3f ',P(iP));
        end
        
        t = text(Xpos(iP)-.25,ax(4)+ax(4)*.2,sprintf(Sig));
        set(t,'fontsize',5);
        
        if P(iP)<Alpha
            set(t,'color','r');
        end
    end
    
end

end