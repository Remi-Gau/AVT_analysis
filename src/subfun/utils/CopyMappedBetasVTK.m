function CopyMappedBetasVTK(Subj, SrcDir, DestDir, opt, Debug)
    % Extract vtk files from a folder tree created by MIPAV/JIST
    % and copies it somewher else

    % Debug == 1
    % the function will look through folders and sub-folders but will not extract anything

    if nargin < 2
        error('Need to know where to look for...');
    end

    if nargin < 3
        DestDir = SrcDir;
    end

    if nargin < 5
        Debug = 1;
    end

    StartDir = pwd;
    cd(SrcDir);

    DirLs = dir;
    IsDir = find([DirLs.isdir]);

    BetaName = [];

    for iDir = 3:length(IsDir)

        if DirLs(IsDir(iDir)).isdir
            fprintf('Anaysing directory: %s\n', DirLs(IsDir(iDir)).name);
            BetaName =  ListSubDir(DirLs(IsDir(iDir)).name, DestDir, BetaName, Subj, opt, Debug);
        end

        fprintf('\n');

    end

    cd(StartDir);

end

function BetaName = ListSubDir(DirName, DestDir, BetaName, Subj, opt, debug)
    % Recursive function that explores all subdirectories

    cd(DirName);
    DirLs = dir;

    if sum([DirLs(:).isdir]) - 2 > 0

        IsDir = find([DirLs.isdir]);

        for iDir = 3:length(IsDir)

            if strcmp(DirLs(IsDir(iDir)).name, 'ProfileSampling')
                fprintf('  Analysing directory: %s\n', fullfile(DirName, 'ProfileSampling'));
                BetaName = ExtractBetaName(Subj, opt);

            elseif exist(fullfile(DirLs(IsDir(iDir)).name, 'ProfileSampling.input'), 'file')
                fprintf('  Analysing directory: %s\n', fullfile(DirName, 'ProfileSampling'));
                cd(fullfile(DirLs(IsDir(iDir)).name));
                BetaName = ExtractBetaName(Subj, opt);
                cd ..;

            elseif strcmp(DirLs(IsDir(iDir)).name, 'SurfaceMeshMapping')
                fprintf('  Analysing directory: %s\n', fullfile(DirName, 'SurfaceMeshMapping'));
                ExtractFile(DestDir, BetaName, Subj, opt, debug);

            else
                fprintf(' Anaysing directory: %s\n', DirLs(IsDir(iDir)).name);
                BetaName = ListSubDir(DirLs(IsDir(iDir)).name, DestDir, BetaName, Subj, opt, debug);

            end
        end
    end
    cd ..;
end

function ExtractFile(DestDir, BetaName, Subj, opt, debug)
    % Gets the information from the file and copies it and changes its name

    FileContent = fileread('SurfaceMeshMapping.input');
    if isempty(BetaName)
        tmp = strfind(FileContent, ['r' Subj]);
        if isempty(tmp)
            try
                warning('Could not identify the source beta image: trying to fix this.');
                BetaName = ExtractBetaName(Subj, opt, 1);
            catch
                error('Could not identify the source beta image.');
            end
        else
            BetaName = FileContent(tmp(1) + 13:tmp(1) + 16);
        end
    end

    tmp2 = strfind(FileContent, 'lcr_gm_avg.vtk');
    if ~isempty(tmp2)
        hs_sufix = 'l';

    else
        tmp2 = strfind(FileContent, 'rcr_gm_avg.vtk');
        if ~isempty(tmp2)
            hs_sufix = 'r';

        else
            error('Not sure which hemisphere this came from.');

        end
    end

    cd('SurfaceMeshMapping');
    File = dir('*.vtk');

    disp(['   Beta_' BetaName '_' hs_sufix 'cr.vtk']);

    if ~debug
        copyfile(fullfile(pwd, File.name), ...
                 fullfile(DestDir, ['Beta_' BetaName '_' hs_sufix 'cr.vtk']));
    end

    cd ..;
end

% Gets the information from the file and copies it and changes its name
function BetaName = ExtractBetaName(Subj, opt, Catch)

    if nargin < 3 || Catch == 0 || isempty(Catch)
        FileContent = fileread('ProfileSampling.input');

    else
        InputFile = dir(fullfile(pwd, '..', '*-A.input'));
        FileContent = fileread(fullfile(pwd, '..', InputFile.name));

    end

    tmp = strfind(FileContent, ['r' Subj opt.beta_mapping_pattern]);
    pat_length = numel(['r' Subj opt.beta_mapping_pattern]);
    if isempty(tmp)
        BetaName = tmp;

    else
        BetaName = FileContent(tmp(1) + pat_length:tmp(1) + pat_length + 3);

    end

end
