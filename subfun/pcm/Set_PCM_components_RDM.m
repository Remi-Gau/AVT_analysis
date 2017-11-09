function [Components, h] = Set_PCM_components_RDM(print, FigDim)

%% Set the different pattern components using RDMs

fprintf('Preparing pattern components\n')

CondNames = {...
    'A contra','A ipsi',...
    'V contra','V ipsi',...
    'T contra','T ipsi'...
    };

ID_Matrix = eye(numel(CondNames));
BaseMatrix = 1-eye(numel(CondNames)); %ones(numel(CondNames));

SensMod = BaseMatrix;
SensMod(1:2,1:2)=0;
SensMod(3:4,3:4)=0;
SensMod(5:6,5:6)=0;
Components(1).mat = SensMod;
Components(end).name = [num2str(numel(Components)) '-Sensory modalities'];

SensMod = BaseMatrix;
SensMod(1:2,1:2)=0;
Components(end+1).mat = SensMod;
Components(end).name = [num2str(numel(Components)) '-A stim'];

SensMod = BaseMatrix;
SensMod(3:4,3:4)=0;
Components(end+1).mat = SensMod;
Components(end).name = [num2str(numel(Components)) '-V stim'];

SensMod = BaseMatrix;
SensMod(5:6,5:6)=0;
Components(end+1).mat = SensMod;
Components(end).name = [num2str(numel(Components)) '-T stim'];


NonPreferred_A = BaseMatrix;
NonPreferred_A(3:6,3:6)=0;
Components(end+1).mat = NonPreferred_A;
Components(end).name = [num2str(numel(Components)) '-Non Preferred_A'];

NonPreferred_V = BaseMatrix;
NonPreferred_V(1:2,1:2)=0;
NonPreferred_V(1:2,5:6)=0;
NonPreferred_V(5:6,1:2)=0;
NonPreferred_V(5:6,5:6)=0;
Components(end+1).mat = NonPreferred_V;
Components(end).name = [num2str(numel(Components)) '-Non Preferred_V'];


IpsiContra = BaseMatrix;
IpsiContra(1,1)=0; IpsiContra(1,3)=0; IpsiContra(1,5)=0;
IpsiContra(2,2)=0; IpsiContra(2,4)=0; IpsiContra(2,6)=0;
IpsiContra(3,1)=0; IpsiContra(3,3)=0; IpsiContra(3,5)=0;
IpsiContra(4,2)=0; IpsiContra(4,4)=0; IpsiContra(4,6)=0;
IpsiContra(5,1)=0; IpsiContra(5,3)=0; IpsiContra(5,5)=0;
IpsiContra(6,2)=0; IpsiContra(6,4)=0; IpsiContra(6,6)=0;
% IpsiContra(logical(Null))=0;
Components(end+1).mat = IpsiContra;
Components(end).name = [num2str(numel(Components)) '-Ipsi Contra'];

IpsiContra_VT = IpsiContra;
IpsiContra_VT(1:2,:)=1; IpsiContra_VT(:,1:2)=1;
% IpsiContra_VT(1,1)=0; IpsiContra_VT(2,2)=0;
Components(end+1).mat = IpsiContra_VT;
Components(end).name = [num2str(numel(Components)) '-Ipsi Contra_{VT}'];

IpsiContra_A = IpsiContra;
IpsiContra_A(3:6,3:6)=BaseMatrix(3:6,3:6);
Components(end+1).mat = IpsiContra_A;
Components(end).name = [num2str(numel(Components)) '-Ipsi Contra_{A}'];

IpsiContra_AT = IpsiContra;
IpsiContra_AT(3:4,:)=1; IpsiContra_AT(:,3:4)=1;
% IpsiContra_AT(3,3)=0; IpsiContra_AT(4,4)=0;
Components(end+1).mat = IpsiContra_AT;
Components(end).name = [num2str(numel(Components)) '-Ipsi Contra_{AT}'];

IpsiContra_V = IpsiContra;
IpsiContra_V(1:2,5:6)=1; IpsiContra_V(5:6,1:2)=1;
IpsiContra_V(1:2,1:2)=BaseMatrix(1:2,1:2);
IpsiContra_V(5:6,5:6)=BaseMatrix(5:6,5:6);
Components(end+1).mat = IpsiContra_V;
Components(end).name = [num2str(numel(Components)) '-Ipsi Contra_{V}'];



%% Print the RDMs
h = [];
[nVerPan, nHorPan]=rsa.fig.paneling(numel(Components));
if print
    
    h(1) = figure('name', 'Components', 'Position', FigDim, 'Color', [1 1 1]);

    for iCpt = 1:numel(Components)
        
        subplot(nVerPan,nHorPan,iCpt);
        
        colormap('gray');
        
        imagesc(Components(iCpt).mat)
        
        axis on
        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
            'ytick', 1:6,'yticklabel', CondNames, ...
            'ticklength', [0.01 0], 'fontsize', 6)
        box off
        axis square
        
        t=title(Components(iCpt).name);
        set(t, 'fontsize', 8);
    end
    
    mtit('Pattern components: RDMs', 'fontsize', 10, 'xoff',0,'yoff',.035);
    
end

%% transform the RDM in G matrices
fprintf('Converting components RDMs to G matrices\n')
for iCpt = 1:numel(Components)
    fprintf(' Converting component %s\n',Components(iCpt).name)
    Components(iCpt).G=nearestSPD(rdm2G(Components(iCpt).mat,0));
%     Components(iCpt).G = pcm_makePD(rdm2G(Components(iCpt).mat,0));
end

%% Print the G matrices
if print
    
    h(2) = figure('name', 'Components', 'Position', FigDim, 'Color', [1 1 1]);
    
    for iCpt = 1:numel(Components)
        
        subplot(nVerPan,nHorPan,iCpt);
        
        colormap('gray');
        
        imagesc(Components(iCpt).G)
        
        axis on
        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
            'ytick', 1:6,'yticklabel', CondNames, ...
            'ticklength', [0.01 0], 'fontsize', 6)
        box off
        axis square
        
        t=title(Components(iCpt).name);
        set(t, 'fontsize', 8);
    end
    
    mtit('Pattern components: G matrices', 'fontsize', 10, 'xoff',0,'yoff',.035);
    
end


end

