clear; clc

StartDir = fullfile(pwd, '..','..', '..');
cd (StartDir)

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';

for iSub = [1 3 5:NbSub]
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    
    cd(fullfile(SubDir, 'ffx_nat', 'betas'))
    
    Mask = spm_read_vols(spm_vol(fullfile(SubDir, 'ffx_nat', 'betas', ...
        [SubLs(iSub).name '_GLM_mask.nii'])));
    
    BetaFiles = dir(['r' SubLs(iSub).name '_beta-*.nii.gz']);
    
    fprintf(1,'   [%s]\n   [ ',repmat('.',1,size(BetaFiles,1)));
    
    parfor iBeta = 1:numel(BetaFiles)
        
        % decompress .gz file and deletes it
        gunzip(BetaFiles(iBeta).name) 
        delete(BetaFiles(iBeta).name)
        
        % make all values outside the mask equal to 0
        hdr = spm_vol(BetaFiles(iBeta).name(1:end-3));
        vol = spm_read_vols(hdr);
        vol(Mask==0)=0;
        
        % overwrite the original file
        spm_write_vol(hdr,vol);
        hdr=[]; vol=[];
        
        % compress .nii file in a .gz and then deletes the .nii file
        gzip(BetaFiles(iBeta).name(1:end-3))
        delete(BetaFiles(iBeta).name(1:end-3))
        
        fprintf(1,'\b.\n');
    end
    fprintf(1,'\b]\n');
    
end
