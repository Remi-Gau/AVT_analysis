function RSA_featPool_vol

clear; close all; clc

whitened_beta = 0;

Start_dir = fullfile(pwd, '..','..','..','..');
addpath(genpath(fullfile(Start_dir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox')

Subj_list = dir(fullfile(Start_dir,'sub-*'));
NbSubj = numel(Subj_list);

% --------------------------------------------------------- %
%                            ROIs                           %
% --------------------------------------------------------- %

Mask_Ori.ROI(1,1) = struct('name', 'V1_L_thres', 'fname', 'SubjName_lcr_V1_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(1,2) = struct('name', 'V1_R_thres', 'fname', 'SubjName_rcr_V1_Pmap_Ret_thres_10_data.nii');

Mask_Ori.ROI(end+1,1) = struct('name', 'V2_L_thres', 'fname', 'SubjName_lcr_V2_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end,2) = struct('name', 'V2_R_thres', 'fname', 'SubjName_rcr_V2_Pmap_Ret_thres_10_data.nii');

Mask_Ori.ROI(end+1,1) = struct('name', 'V3_L_thres', 'fname', 'SubjName_lcr_V3_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end,2) = struct('name', 'V3_R_thres', 'fname', 'SubjName_rcr_V3_Pmap_Ret_thres_10_data.nii');

Mask_Ori.ROI(end+1,1) = struct('name', 'V4_L_thres', 'fname', 'SubjName_lcr_V4_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end,2) = struct('name', 'V4_R_thres', 'fname', 'SubjName_rcr_V4_Pmap_Ret_thres_10_data.nii');

Mask_Ori.ROI(end+1,1) = struct('name', 'V5_L_thres', 'fname', 'SubjName_lcr_V5_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end,2) = struct('name', 'V5_R_thres', 'fname', 'SubjName_rcr_V5_Pmap_Ret_thres_10_data.nii');

Mask_Ori.ROI(end+1,1) = struct('name', 'A1_L', 'fname', 'SubjName_A1_lcr_RG_data.nii');
Mask_Ori.ROI(end,2) = struct('name', 'A1_R', 'fname', 'SubjName_A1_rcr_RG_data.nii');

Mask_Ori.ROI(end+1,1) = struct('name', 'PT_L', 'fname', 'rwA41-42_L.nii');
Mask_Ori.ROI(end,2) = struct('name', 'PT_R', 'fname', 'rwA41-42_R.nii');

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR',...
    'ATargL','ATargR',...
    'VTargL','VTargR',...
    'TTargL','TTargR',...
    };

for iSubj=1:NbSubj
    
    Subj_ID = Subj_list(iSubj).name;
    
    fprintf('Analysing subject %s\n', Subj_ID)
    
    Subj_dir = fullfile(Start_dir,Subj_ID);
    GLM_dir = fullfile(Subj_dir,'ffx_nat');
    ROI_dir = fullfile(Subj_dir,'roi','vol','mni','upsamp');
    if whitened_beta
        Data_dir = fullfile(Subj_dir,'ffx_rsa','betas');
    else
        Data_dir = fullfile(Subj_dir,'ffx_nat','betas');
    end
    Save_dir = fullfile(Subj_dir,'results','rsa','vol');
    
    mkdir(Save_dir)
    
    GLM_mask = fullfile(Subj_dir,'ffx_nat','betas', ['r' Subj_ID '_GLM_mask.nii']);
    
    Mask = Mask_Ori;
    
    for iROI =1:numel(Mask.ROI)
        Mask.ROI(iROI).fname = strrep(Mask_Ori.ROI(iROI).fname,'SubjName',Subj_list(iSubj).name);
    end
    clear iROI
    
    %% Get masks
    fprintf(' Getting mask and ROI data\n')
    
    Mask_hdr = spm_vol(GLM_mask);
    Mask_img = spm_read_vols(Mask_hdr);
    [X, Y, Z] = ind2sub(size(Mask_img), find(Mask_img));
    Mask_XYZ = [X'; Y'; Z']; % XYZ format
    clear X Y Z
    Mask_XYZmm = Mask_hdr.mat(1:3,:) ...
        * [Mask_XYZ; ones(1, size(Mask_XYZ,2))]; % voxel to world transformation
    
    xY.def = 'mask';
    
    for iROI=1:numel(Mask.ROI)
        xY.spec = fullfile(ROI_dir, Mask.ROI(iROI).fname);
        [xY, Mask.ROI(iROI).XYZmm, j] = spm_ROI(xY,Mask_XYZmm);
        Mask.ROI(iROI).XYZ = Mask_XYZ(:,j);
        Mask.ROI(iROI).size = size(Mask.ROI(iROI).XYZ, 2);
    end
    clear xY j
    
    %% Get Betas of interests
    fprintf(' Getting info from SPM.mat\n')
    
    load(fullfile(GLM_dir,'SPM.mat'))
    [~, BetaNames] = GetBOI(SPM,CondNames);
    
    
    %% Get data
    if whitened_beta
        Data_file_name = fullfile(Save_dir, [Subj_ID '_data_whitened_betas.mat']);
    else
        Data_file_name = fullfile(Save_dir, [Subj_ID '_data_raw_betas.mat']);
    end
    
    fprintf(' Getting data\n')
    if exist(Data_file_name, 'file')
        load(Data_file_name, ...
            'Features')
    else
        
        % Check files
        [~, Files2unzip, Files2reslice] = Check_files(CondNames, BetaNames, Data_dir, Subj_ID, whitened_beta);
        
        % unzip files if necessary
        if ~isempty(Files2unzip)
            fprintf('  Unzipping beta files\n')
            for iFile=1:numel(Files2unzip)
                fprintf('  unzipping %s\n', Files2unzip{iFile})
                gunzip(Files2unzip{iFile})
                a = dir(Files2unzip{iFile}(1:end-3));
                if isempty(a) || a.bytes<448000000
                    Files2reslice{end+1,1} = [a(2:end-3) ',1']; %#ok<*SAGROW>
                end
            end
        end
        
        % Reslice problematic volumes
        if ~isempty(Files2reslice)
            fprintf('  Reslicing beta files\n')
            Reslice(Files2reslice, GLM_mask)
        end
        
        % Check files
        [Data_files, Files2unzip, Files2reslice] = Check_files(CondNames, BetaNames, Data_dir, Subj_ID, whitened_beta);
        if ~isempty(Files2reslice) || ~isempty(Files2unzip)
            error('some problem appeared')
        end
        
        
        fprintf('  Reading features\n')
        V = spm_vol(char(Data_files));
        
        fprintf(1,'   [%s]\n   [ ',repmat('.', 1, numel(Mask.ROI)) );
        
        parfor iROI=1:numel(Mask.ROI)
            tmp = spm_get_data(V, Mask.ROI(iROI).XYZ); %#ok<*PFBNS>
            FeaturesTmp{iROI} = tmp;
            fprintf(1,'\b.\n');
            tmp = []; %#ok<*NASGU>
        end
        
        fprintf(1,'\b]\n');
        
        % reoganize the data
        for iROI=1:numel(Mask.ROI)
            [x,y] = ind2sub(size(Mask.ROI),iROI);
            Features{x,y}=FeaturesTmp{iROI};
        end
        clear FeaturesTmp
        
        MaskSave = Mask;
        save(Data_file_name, ...
            'Features', 'MaskSave', 'Data_files')
    end
    
    %% run RSA
    if whitened_beta
        Results_file_name = fullfile(Save_dir, [Subj_ID '_results_RSA_whitened_betas.mat']);
    else
        Results_file_name = fullfile(Save_dir, [Subj_ID '_results_RSA_raw_betas.mat']);
    end
    
    
    for iHS = 1:2
        for iROI=1:size(Mask.ROI,1)
            
            fprintf(' Processing %s\n', Mask.ROI(iROI,iHS).name)
            
            Data = Features{iROI,iHS};
            
            % removes columns of zeros or Nans
            ToRemove = any([all(isnan(Data)); all(Data==0)]);
            Data(:,ToRemove) = [];
            clear ToRemove

            for iTarget=0:1
                
                X = Data;
                
                if iSubj == 5
                    conditionVec = repmat(1:numel(CondNames),numel(SPM.Sess),1);
                    conditionVec = conditionVec(:);
                    
                    partitionVec = repmat((1:numel(SPM.Sess))',numel(CondNames),1);
                    
                    ToRemove = all([any([conditionVec<3 conditionVec==6 conditionVec==7],2) partitionVec==17],2);
                    
                    partitionVec(ToRemove) = [];
                    conditionVec(ToRemove) = [];
                    
                    ToRemove = partitionVec==17;
                    
                    partitionVec(ToRemove) = [];
                    conditionVec(ToRemove) = [];
                    
                else
                    conditionVec = repmat(1:numel(CondNames),numel(SPM.Sess),1);
                    conditionVec = conditionVec(:);
                    
                    partitionVec = repmat((1:numel(SPM.Sess))',numel(CondNames),1);
                end
                
                if iTarget==0
                    conditionVec(conditionVec>6)=0;
                else
                    conditionVec(conditionVec<7)=0;
                    conditionVec(conditionVec>6)=conditionVec(conditionVec>6)-6;
                end

                % removes rows of zeros or Nans
                ToRemove = any([all(isnan(X),2) all(X==0,2)],2);
                partitionVec(ToRemove)=[]; conditionVec(ToRemove)=[];
                X(ToRemove,:) = [];
                clear ToRemove
                
                % remove condition of no interests
                X(conditionVec==0,:)=[];
                partitionVec(conditionVec==0,:)=[];
                conditionVec(conditionVec==0,:)=[];
                
                % Eucledian normalization
                for i=1:size(X, 1)
                    X(i,:) = X(i,:) / norm(X(i,:));
                end 
                clear i
                
                A =  rsa.distanceLDC(X, partitionVec, conditionVec);
                B =  rsa.distanceLDC(flipud(X), flipud(partitionVec), conditionVec);
                B = fliplr(B);
                RDMs{iROI,iHS,iTarget+1} = squareform(mean([A;B]));
                
                clear X conditionVec partitionVec A B
            end
            
            clear Data
        end
    end
    
    clear iHS iROI
    
    save(Results_file_name, ...
            'RDMs', 'Mask')
end

end


function [Data_files, Files2unzip, Files2reslice] = Check_files(CondNames, BetaNames, Data_dir, Subj_ID, whitened_beta)

Data_files = {};
Files2unzip = {};
Files2reslice = {};

if whitened_beta
    beta_prefix = 'w';
else
    beta_prefix = '';
end

for iCond = 1:numel(CondNames)
    
    tmp = find(~cellfun(@isempty,strfind(cellstr(BetaNames),[CondNames{iCond} '*bf(1)'])));
    
    for iFile=1:numel(tmp)
        
        File = spm_select('FPList', fullfile(Data_dir), ...
            sprintf('^r%s_%sbeta-%04.0f.nii$',Subj_ID,beta_prefix,tmp(iFile)) );
        
        if isempty(File)
            
            % check if file has been zipped
            Zipped_file = spm_select('FPList', fullfile(Data_dir), ...
                sprintf('^r%s_%sbeta-%04.0f.nii.gz$',Subj_ID,beta_prefix,tmp(iFile)) ) ;
            
            if isempty(Zipped_file)
                
                % if file is not there as zipped we reslice the
                % original one
                Original_file = spm_select('FPList', fullfile(Data_dir), ...
                    sprintf('^%s_%sbeta-%04.0f.nii$',Subj_ID,beta_prefix,tmp(iFile)) );
                
                if isempty(Original_file)
                    error('An orginal beta file is missing.')
                else
                    Files2reslice{end+1,1} = Original_file; %#ok<*AGROW>
                end
                
            else
                Files2unzip{end+1}=Zipped_file;
            end
            
        else
            
            a = dir(File);
            [path,name,ext] = fileparts(File);
            if isempty(a) || a.bytes<448000000
                Files2reslice{end+1,1} = fullfile(path,[name(2:end) ext ',1']); %#ok<*SAGROW>
            else
                Data_files{end+1} = File;
            end
            
        end
        
    end
end

end


function Reslice(Files2reslice, Ref)

matlabbatch = {};

% For betas
matlabbatch{1}.spm.spatial.coreg.write.ref = {Ref};
matlabbatch{1}.spm.spatial.coreg.write.source = Files2reslice;
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run', matlabbatch)

end

