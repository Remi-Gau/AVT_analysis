function FeaturesAll = GetFeatures(Mask, FilesList, AnalysisFolder, NbLayers)

FeaturesAll = cell(1, length(Mask));

%% Decompress
fprintf(' Decompressing images if necessary\n')
fprintf(1,'   [%s]\n   [ ',repmat('.', 1, size(FilesList,1)) );
parfor i=1:size(FilesList,1)
    if ~exist(FilesList{i,1}, 'file')
        try
            gunzip([FilesList{i,1} '.gz']);
        catch
            warning(['The beta image ' FilesList{i,1} ' is missing.'])
        end
    end
    fprintf(1,'\b.\n');
end
fprintf(1,'\b]\n');

%% Check that we have all the files and that that have the right size
Files2Reslice = {};
for i=1:numel(FilesList)
    a = dir(FilesList{i});
    [PathStr,Name,Ext] = fileparts(FilesList{i});
    if isempty(a)
        Files2Reslice{end+1,1} = fullfile(PathStr, [Name(2:end) Ext ',1']); %#ok<*SAGROW>
    elseif a.bytes<448000000
        Files2Reslice{end+1,1} = fullfile(PathStr, [Name(2:end) Ext ',1']); %#ok<*SAGROW>        
    end
end
% Reslice problematic volumes
if ~isempty(Files2Reslice)
    Reslice(Files2Reslice, AnalysisFolder)
end

%% Read features
fprintf(' Reading features\n')
V = spm_vol(char(FilesList));
fprintf(1,'   [%s]\n   [ ',repmat('.', 1, length(Mask)) );
parfor i=1:length(Mask)
    tmp = spm_get_data(V, Mask(i).XYZ); %#ok<*PFBNS>
    FeaturesAll{i} = tmp;
    fprintf(1,'\b.\n');
    tmp = []; %#ok<*NASGU>
end
fprintf(1,'\b]\n');

for i=1:length(Mask)
    MaskSave = Mask(i);
    FilesListSave = FilesList;
    Features = FeaturesAll(i);
    save(fullfile(AnalysisFolder, ['BOLD_' Mask(i).name '_data_l-' num2str(NbLayers) '.mat']), ...
        'Features', 'MaskSave', 'FilesListSave')
end

end
