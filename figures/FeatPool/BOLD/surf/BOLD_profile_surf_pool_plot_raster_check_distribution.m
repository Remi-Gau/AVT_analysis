clc; clear;

StartDir = fullfile(pwd, '..','..','..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };

CondNames2Plot = {...
    'A Stim Ipsi','A Stim Contra',...
    'V Stim Ipsi','V Stim Contra',...
    'T Stim Ipsi','T Stim Contra'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers-2,1) DesMat'];
DesMat = spm_orth(DesMat);


load(fullfile(StartDir,'results','roi','MinNbVert.mat'),'MinVert')

%First column: sorting condition; second column: condition to sort
% we need different ones for the left and right ROIs becuase of the ipsi
% and contra pooling
A=repmat(1:6,6,1);
Cdt_ROI_lhs = [A(:), repmat([1:6]',6,1)]; %#ok<*NBRAK>
clear A

A=repmat([2 1 4 3 6 5],6,1);
Cdt_ROI_rhs = [A(:), repmat([2 1 4 3 6 5]',6,1)];
clear A



% Color map
X = 0:0.001:1;

R = 0.237 - 2.13*X + 26.92*X.^2 - 65.5*X.^3 + 63.5*X.^4 - 22.36*X.^5;
G = ((0.572 + 1.524*X - 1.811*X.^2)./(1 - 0.291*X + 0.1574*X.^2)).^2;
B = 1./(1.579 - 4.03*X + 12.92*X.^2 - 31.4*X.^3 + 48.6*X.^4 - 23.36*X.^5);
ColorMap1 = [R' G' B'];

R = 1 - 0.392*(1 + erf((X - 0.869)/ 0.255));
G = 1.021 - 0.456*(1 + erf((X - 0.527)/ 0.376));
B = 1 - 0.493*(1 + erf((X - 0.272)/ 0.309));
ColorMap2 = [R' G' B'];
ColorMap2 = flipud(ColorMap2);

clear X R G B



for iSub = 1 %:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    Fig_dir = fullfile(Sub_dir, 'fig', 'profiles', 'surf');    
    mkdir(Fig_dir)
    
    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM
    
    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI',  'NbVertex')
    
    
    %% For the 2 hemispheres
    NbVertices = nan(1,2);
    for hs = 1:2
        
        if hs==1
            fprintf('\n Left hemipshere\n')
            HsSufix = 'l';
        else
            fprintf('\n Right hemipshere\n')
            HsSufix = 'r';
        end
        
        FeatureSaveFile = fullfile(Data_dir,[SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
            num2str(NbLayers) '_surf.mat']);
      
        % Load data or extract them
        fprintf('  Reading VTKs\n')
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile)
            VertexWithDataHS{hs} = VertexWithData;
        else
            error('The features have not been extracted from the VTK files.')
        end
        
        
        %% Run GLMs for basic conditions
        fprintf('\n  Running GLMs all conditions\n')
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('   %s\n',CondNames{iCdt})
            
            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end

            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            
            % Extract them
            Features = AllMapping(:,:,Beta2Sel); %#ok<*FNDSB>
            
            % Saves mean of all the features across sessions for the raster
            FeaturesCdtion{iCdt,hs} = mean(Features,3);
            
            % Change or adapt dimensions for GLM
            X=repmat(DesMat,size(Features,3),1);
            
            Y = shiftdim(Features,1);
            Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
            
            B = pinv(X)*Y;
            
            BetaCdt{hs}(:,:,iCdt) = B; %#ok<*SAGROW>
            
            C = Y - X*B;
%             C = reshape(C,[6,20,size(C,2)]);
%             C = squeeze(mean(C,2))';
            
            Residuals{iCdt,hs} = C;
            
            clear Features Beta2Sel B C X Y Mapping iBeta iSess
        end
        
        clear iCdt
        
    end

    cd(StartDir)

    
    %%
    for iROI = 1 %:numel(ROI)

        close all
        
        %%
        for iCdt = 4 %1:6
        % Varibles to sort
        Profiles_lh = nan(NbVertex(1),6);
        Profiles_lh(VertexWithDataHS{1},:) = FeaturesCdtion{iCdt,1};
        Profiles_rh = nan(NbVertex(2),6);
        Profiles_rh(VertexWithDataHS{2},:) = FeaturesCdtion{iCdt,2};
        
        Res_lh = nan(120,NbVertex(1));
        Res_lh(:,VertexWithDataHS{1}) = Residuals{iCdt,1};
        Res_rh = nan(120,NbVertex(2));
        Res_lh(:,VertexWithDataHS{2}) = Residuals{iCdt,2};
        
        Profiles = [...
            Profiles_lh(ROI(iROI).VertOfInt{1},:) ; ...
            Profiles_rh(ROI(iROI).VertOfInt{2},:)];

        Res = [...
            Res_lh(:,ROI(iROI).VertOfInt{1}) ...
            Res_rh(:,ROI(iROI).VertOfInt{2})];
        
        Res(:,any(isnan(Res),1)) = [];
        
        
        C = reshape(Res,[6,20*size(Res,2)]);
        C = fliplr(C');
        COV_all = C'*C;
        
        D = reshape(Res,[6,20,size(Res,2)]);
        for i=1:size(D,3)
            E = D(:,:,i);
            E = fliplr(E');
            Cov_comp(:,:,i) = E'*E;
        end
        Cov_comp=mean(Cov_comp,3);
        
%         ToRemove = cat(3,isnan(Profiles), Profiles==0);
%         ToRemove = any(ToRemove,3);
%         ToRemove = any(ToRemove,2);
%         
%         Profiles(ToRemove,:)=[];
        
        for iLayer = 1:size(Profiles,2) % Averages over voxels of a given layer
            DistToPlot{iLayer} = Profiles(:,iLayer);
            NoiseToPlot{iLayer} = Res(:,iLayer);
        end
        clear iLayer
        
        %%
        close all
        
        h=figure('Name', [ROI(iROI).name ' - ' CondNames2Plot{iCdt}], 'Position', [100, 100, 1500, 1000], 'Color', ...
            [1 1 1], 'Visible', 'on');
        
        
        subplot(3,6,1)
        hold on
        grid on
        
        distributionPlot(DistToPlot, 'xValues', 1:size(Profiles,2), 'color', 'k', ...
            'distWidth', 0.8, 'showMM', 1, 'globalNorm', 2, 'histOpt', 1.1)
        plot([0 size(Profiles,2)+.5], [0 0], '--b')
        
        set(gca,'tickdir', 'out', 'xtick', 1:size(Profiles,2) , ...
            'xticklabel',1:size(Profiles,2), 'ytick', -20:5:20 , ...
            'yticklabel',-20:5:20, ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        axis([0 size(Profiles,2)+.5 min(Profiles(:)) max(Profiles(:))])
        
        t=title('Data dist');
        set(t,'fontsize',12);
        t=xlabel('layer');
        set(t,'fontsize',12);
        

        subplot(3,6,2)
        hold on
        grid on
        
        plot(nanstd(Profiles), '-ob', 'linewidth',2 )

        set(gca,'tickdir', 'out', 'xtick', 1:size(Profiles,2) , ...
            'xticklabel',1:size(Profiles,2), 'ytick', -20:1:20 , ...
            'yticklabel',-20:1:20, ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        axis([0 size(Profiles,2)+.5 0 5])
        
        t=title('Data: STD');
        set(t,'fontsize',12);
        t=xlabel('layer');
        set(t,'fontsize',12);
        
        
        subplot(3,6,3)
        colormap(ColorMap1)
        COV=nancov(Profiles);
        imagesc(flipud(nancov(COV)), [-1*max(abs(COV(:))) max(abs(COV(:)))])
        axis('square')
        set(gca,'tickdir', 'out', 'xtick', 1:size(Profiles,2) , 'xticklabel',1:size(Profiles,2), ...
            'ytick', 1:size(Profiles,2) , 'yticklabel',size(Profiles,2):-1:1, 'ticklength', [0.01 0.01], 'fontsize', 12)
        t=title('Data cov');
        set(t,'fontsize',12);
        t=xlabel('layer');
        set(t,'fontsize',12);
        t=ylabel('layer');
        set(t,'fontsize',12);
        colorbar
        
        
        
        
        subplot(3,6,4)
        hold on
        grid on
        
        distributionPlot(NoiseToPlot, 'xValues', 1:size(Profiles,2), 'color', 'k', ...
            'distWidth', 0.8, 'showMM', 1, 'globalNorm', 2, 'histOpt', 1.1)
        plot([0 size(Profiles,2)+.5], [0 0], '--k')
        
        set(gca,'tickdir', 'out', 'xtick', 1:size(Profiles,2) , ...
            'xticklabel',1:size(Profiles,2), 'ytick', -20:1:20 , ...
            'yticklabel',-20:1:20, ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        axis([0 size(Profiles,2)+.5 min(Res(:))/2 max(Res(:))/2])
        
        t=title('Residuals dist');
        set(t,'fontsize',12);
        t=xlabel('layer');
        set(t,'fontsize',12);

        
        
        subplot(3,6,5)
        hold on
        grid on
        
        plot(nanstd(Res), '-ok', 'linewidth',2 )

        set(gca,'tickdir', 'out', 'xtick', 1:size(Profiles,2) , ...
            'xticklabel',1:size(Profiles,2), 'ytick', -20:1:20 , ...
            'yticklabel',-20:1:20, ...
            'ticklength', [0.01 0.01], 'fontsize', 12)
        axis([0 size(Profiles,2)+.5 0 5])
        
        t=title('Residuals: STD');
        set(t,'fontsize',12);
        t=xlabel('layer');
        set(t,'fontsize',12);
        
        
        subplot(3,6,6)
        colormap(ColorMap1)
        COV=nancov(Res);
        imagesc(flipud(nancov(COV)), [-1*max(abs(COV(:))) max(abs(COV(:)))])
        axis('square')
        set(gca,'tickdir', 'out', 'xtick', 1:size(Profiles,2) , 'xticklabel',1:size(Profiles,2), ...
            'ytick', 1:size(Profiles,2) , 'yticklabel',size(Profiles,2):-1:1, 'ticklength', [0.01 0.01], 'fontsize', 12)
        t=title('Residuals cov');
        set(t,'fontsize',12);
        t=xlabel('layer');
        set(t,'fontsize',12);
        t=ylabel('layer');
        set(t,'fontsize',12);
        colorbar
        
        
        
       
        subplot(3,6,[7:9 13:15])
        normplot(Profiles)
        t=legend({'layer 1', 'layer 2', 'layer 3', 'layer 4', 'layer 5', 'layer 6'}, ...
            'location', 'southeast');
        set(t,'fontsize',12);
        
        subplot(3,6,[10:12 17:18])
        normplot(Res)
        t=legend({'layer 1', 'layer 2', 'layer 3', 'layer 4', 'layer 5', 'layer 6'}, ...
            'location', 'southeast');
        set(t,'fontsize',12);
        
        
        mtit([ROI(iROI).name ' - ' CondNames2Plot{iCdt}], 'xoff', 0, 'yoff', +0.05, 'fontsize', 16)

        
        FileName = fullfile(Fig_dir, strrep([ROI(iROI).name '-' CondNames2Plot{iCdt} '.tiff'],' ','_'));
        
        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,FileName,'tiff');
        
        
        end
    end
    
    
    %% Profiles stim = f(other stim)    
    ToPlot={'Cst','Lin','Quad'};
    
    fprintf('\n')
    
    for iToPlot = 1 %:numel(ToPlot)

        for iROI = 1:numel(ROI)
            
            NbBin = MinVert(strcmp(ROI(iROI).name,{MinVert.name}')).MinVert;

            parfor iCdt = 1:size(Cdt_ROI_lhs,1)
                
                % Sorting varibles
                X_lh = nan(1,NbVertex(1));
                X_lh(1,VertexWithDataHS{1}) = BetaCdt{1}(iToPlot,:,Cdt_ROI_lhs(iCdt,1)); %#ok<*PFBNS>
                X_rh = nan(1,NbVertex(2));
                X_rh(1,VertexWithDataHS{2}) = BetaCdt{2}(iToPlot,:,Cdt_ROI_rhs(iCdt,1));
                
                % Varibles to sort
                Profiles_lh = nan(NbVertex(1),6);
                Profiles_lh(VertexWithDataHS{1},:) = FeaturesCdtion{Cdt_ROI_lhs(iCdt,2),1};
                Profiles_rh = nan(NbVertex(2),6);
                Profiles_rh(VertexWithDataHS{2},:) = FeaturesCdtion{Cdt_ROI_rhs(iCdt,2),2};
                
                % Sort
                X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
                [X_sort,I] = sort(X);
                
                Profiles = [...
                    Profiles_lh(ROI(iROI).VertOfInt{1},:) ; ...
                    Profiles_rh(ROI(iROI).VertOfInt{2},:)];
                Profiles = Profiles(I,:);
                
                ToRemove = cat(3,isnan(Profiles), Profiles==0);
                ToRemove = any(ToRemove,3);
                ToRemove = any(ToRemove,2);
                
                Profiles(ToRemove,:)=[];
                X_sort(ToRemove)=[];

                IdxToAvg = floor(linspace(1,numel(X_sort),NbBin+1));
                
                X_sort_Perc=[];
                Profiles_Perc=[];
                
                for iPerc = 2:numel(IdxToAvg)
                    X_sort_Perc(iPerc-1) = mean(X_sort(IdxToAvg((iPerc-1):iPerc)));
                    Profiles_Perc(iPerc-1,:) = mean(Profiles(IdxToAvg((iPerc-1):iPerc),:));
                end
                
                X_sort=[]; %#ok<*NASGU>
                Profiles=[];
                
                X_sort = X_sort_Perc;
                Profiles = Profiles_Perc;

                All_Profiles{iSub, iToPlot, iCdt, iROI} = Profiles;
                All_X_sort{iSub, iToPlot, iCdt, iROI} = X_sort;

                
                X = [];
                
            end
            
            clear X_lh Y_rh

        end

    end

    clear BetaCdt FeaturesCdtion 
    
end

cd(StartDir)


