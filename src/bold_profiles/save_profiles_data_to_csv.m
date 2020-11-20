%%
% This script computes the bold profile for for each condition, session,
% subject and saves it in a different file for each ROI

clc;
clear;

ROIs = {
        'A1'
        'PT'
        'V1'
        'V2'};

Median = 1; % if set to 0 will compute mean

% to decide if we extract the data from the base sitmuli (1) or from the
% target stimuli (0)
Stim = 0;

%% set up directories and get dependencies
if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
else
    disp('Platform not supported');
end

addpath(genpath(fullfile(CodeDir, 'subfun')));

[Dirs] = set_dir();

Get_dependencies();

Data_dir = fullfile(Dirs.DerDir, 'DataToExport', 'extracted_betas');
Results_dir = fullfile(Dirs.DerDir, 'DataToExport', 'BOLD_profiles');
mkdir(Results_dir);

%%
NbLayers = 6;
LayerInd = NbLayers:-1:1;

if Stim
    CondNames = { ...
                 'AStimL', 'AStimR', ...
                 'VStimL', 'VStimR', ...
                 'TStimL', 'TStimR'};
    label = 'stim';
else
    CondNames = { ...
                 'ATargL', 'ATargR', ...
                 'VTargL', 'VTargR', ...
                 'TTargL', 'TTargR' ...
                };
    label = 'target';
end

SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
NbSub = numel(SubLs);

fprintf(' Saving for ROI:\n');

for iROI = 1:numel(ROIs)

    fprintf(['  '  ROIs{iROI} '\n']);

    Data = [];

    for iSub = 1:NbSub

        fprintf('\n\n\n');

        fprintf('Processing %s\n', SubLs(iSub).name);

        subj = str2double(SubLs(iSub).name(5:end));

        Features = [];

        LayerLabels = [];

        for hs = 1:2

            if hs == 1
                fprintf('\n Left hemipshere\n');
                HsSufix = 'l';
            else
                fprintf('\n Right hemipshere\n');
                HsSufix = 'r';
            end

            FileName = strcat( ...
                              'sub-', SubLs(iSub).name, ...
                              '_data-surf_cdt-', label, '_ROI-', ROIs{iROI}, ...
                              '_hs-', HsSufix);

            load(fullfile(Data_dir, [FileName '.mat']), ...
                 'Features_ROI', 'LayerLabel', ...
                 'CdtVect', 'SessVect');

            Features = [Features Features_ROI]; %#ok<*AGROW>

            LayerLabels = [LayerLabels; LayerLabel];

            clear Features_ROI LayerLabel;
        end

        for  iCdt = 1:max(CdtVect)
            for iSess = 1:max(SessVect)

                Data(end + 1, :) = [subj iCdt iSess nan(1, NbLayers)]; %#ok<*SAGROW>

                row_to_select = all([CdtVect == iCdt SessVect == iSess], 2);
                row = Features(row_to_select, :);

                if ~isempty(row)

                    for iLayer = LayerInd

                        if Median
                            Data(end, 3 + iLayer) = nanmedian(row(LayerLabels == iLayer));
                        else

                            Data(end, 3 + iLayer) = nanmean(row(LayerLabels == iLayer));
                        end

                    end

                end

            end
        end

        clear CdtVect SessVect;

    end

    %% saves the data

    Labels = Data(:, 1:3);
    Data = fliplr(Data(:, 4:end));

    FileName = ['group_data-surf_cdt-', label, '_ROI-', ROIs{iROI}, '_hs-both'];

    % save to .mat
    save(fullfile(Results_dir, [FileName '.mat']), 'Data', 'Labels');

    % save to .csv
    fid = fopen (fullfile(Results_dir, [FileName '.csv']), 'w');
    for iRow = 1:size(Labels, 1)
        fprintf (fid, 'sub-%i,', Labels(iRow, 1));
        fprintf (fid, 'ses-%i,', Labels(iRow, 3));
        fprintf (fid, '%s,', CondNames{Labels(iRow, 2)});
        fprintf (fid, '%f,', Data(iRow, :));
        fprintf (fid, '\n');
    end
    fclose (fid);

end
