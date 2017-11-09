clear; clc

StartDir = fullfile(pwd, '..','..', '..');
cd (StartDir)
addpath(fullfile(StartDir, 'code', 'subfun'))

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

FWHM = 6;

NbWorkers = 2;


ROI(1) = struct('name', 'V1', 'fname', 'rwV1_ProbRet.nii');
ROI(end+1) = struct('name', 'V2', 'fname', 'rwV2_ProbRet.nii');
ROI(end+1) = struct('name', 'V3', 'fname', 'rwV3_ProbRet.nii');
ROI(end+1) = struct('name', 'V4', 'fname', 'rwV4_ProbRet.nii');
ROI(end+1) = struct('name', 'V5', 'fname', 'rwV5_ProbRet.nii');

ROI(end+1) = struct('name', 'TE1.0', 'fname', 'rwTe10_Cyt.nii');
ROI(end+1) = struct('name', 'TE1.1', 'fname', 'rwTe11_Cyt.nii');
ROI(end+1) = struct('name', 'TE1.2', 'fname', 'rwTe12_Cyt.nii');

ROI(end+1) = struct('name', 'STG', 'fname', 'rwHG_STG_AAL.nii');

ROI(end+1) = struct('name', 'S1', 'fname', 'rwS1_Cyt.nii');


% [KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

for iSub = NbSub %[1 3 5:NbSub]
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    RoiFolder = fullfile(SubDir, 'roi', 'vol', 'mni', ['upsamp' filesep]);
    
    % Get ROIs
    ROI_files = [repmat(RoiFolder,numel(ROI),1) char({ROI.fname}')];
    ROI_vols = spm_read_vols(spm_vol(ROI_files));
    
    % Beta
    cd(fullfile(SubDir, 'ffx_nat', 'betas'))
    BetaFiles = dir(['r' SubLs(iSub).name '_beta-05*.nii.gz']);
    
    
    for iLayer = NbLayers % For each number of layer
        %% Get the layer labels
        LayerLabelFile = dir(fullfile(SubDir, 'anat', 'cbs', ...
            ['sub-*_MP2RAGE_T1map_Layers-' sprintf('%02.0f', iLayer) '.nii']));
        
        % Unzip the file if necessary
        if ~isempty(LayerLabelFile)
            LayerLabels = spm_read_vols(spm_vol(fullfile(SubDir, 'anat', 'cbs', ...
                LayerLabelFile.name)));
        else
            try
                LayerLabelFile = dir(fullfile(SubDir, 'anat', 'cbs', ...
                    ['sub-*_MP2RAGE_T1map_Layers-' sprintf('%02.0f', iLayer) '.nii.gz']));
                gunzip(fullfile(SubDir, 'anat', 'cbs', ...
                    LayerLabelFile.name));
                LayerLabels = spm_read_vols(spm_vol(fullfile(SubDir, 'anat', 'cbs', ...
                    LayerLabelFile.name(1:end-3))));
            catch
                error(['The layer label file ' LayerLabels 'is missing.'])
            end
        end
        
        % Check that the number of layers defined by the label file is
        % correct
        if numel(unique(LayerLabels(:)))~=(iLayer+1)
            error('The number of layer in the layer label file seems to be wrong.')
        end
        
        %% Smooth
        for iFWHM = FWHM % for each smoothness
            
            fprintf(' Smoothing at %i mm\n', iFWHM)
            fprintf(1,'   [%s]\n   [ ',repmat('.', 1, size(BetaFiles,1)-numel(dir('r*05*_s-*.nii.gz')) ) );
            
            for iBeta = 1:numel(BetaFiles) % for each beta
                
                % Make sure this is not an already smoothed image
                if isempty(strfind(BetaFiles(iBeta).name, '_s-'))
                    % decompress .gz file and deletes it
                    gunzip(BetaFiles(iBeta).name)
                    
                    Hdr = spm_vol(BetaFiles(iBeta).name(1:end-3));
                    Vol = spm_read_vols(Hdr);

                    % Alloc
                    VolFinal = nan(size(Vol));
                    
                    % Do the smoothing in each ROI
                    for iROI = 1:size(ROI_vols,4)
                        
                        % Smoothing within each layer
                        for i= 1:iLayer 
                            
                            Mask = cat(4, ROI_vols(:,:,:,iROI), ismember(LayerLabels,i));
                            Mask = all(Mask,4);
                            
                            VolTmp = nan(size(Mask));
                            VolTmp(Mask) = Vol(Mask);

                            spm_smooth(VolTmp,VolTmp,iFWHM,0)

                            VolFinal(Mask) = VolTmp(Mask); %#ok<*SAGROW>

                        end
                    
                    end
                    
                    % Nan values in the original beta are transferred to the
                    % final volume
                    VolFinal(isnan(Vol))=Vol(isnan(Vol));
                    
                    % Change name of the header
                    HdrTmp = Hdr;
                    HdrTmp.fname = [HdrTmp.fname(1:end-4) '_l-' num2str(iLayer) '_s-' num2str(iFWHM) '.nii'];
                    
                    % Write the final file
                    spm_write_vol(HdrTmp, VolFinal);
                    
                    % compress the smoothed .nii file and deletes the .nii
                    % files
                    gzip(HdrTmp.fname)
                    delete(HdrTmp.fname)
                    delete(BetaFiles(iBeta).name(1:end-3))
                    
                    fprintf(1,'\b.\n');
                end
                
            end
            fprintf(1,'\b]\n');
        end
        
    end
    
    cd(StartDir)
end

% CloseParWorkersPool(KillGcpOnExit)