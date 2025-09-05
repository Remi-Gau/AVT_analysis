% (C) Copyright 2020 Remi Gau
%% Phase enconded lines (PELines) and ReadOutTime
% PELines = ((BaseResolution * PartialFourier)/iPat) + ((iPat-1)/iPAT) * ReferenceLines) =
% ReadoutDuration = PELines * InterEchoSpacing

% GRAPPA=iPAT4 ; Partial Fourrier=6/8 ; 48 sli ; TE=25ms ; Res=0.75 mm
% Bandwidth Per Pixel Phase Encode = 15.873

%% According to Robert Trampel

% For distortion correction: ignore Partial Fourrier and references lines
% BaseResolution/iPAT = PELines

% Effective echo spacing: 2 ways to calculate, should be the same
% 1/(Bandwidth Per Pixel Phase Encode * Reconstructed phase lines) -->  0.246 ms
% echo spacing (syngo) / iPAT

% SPM Total readout time = 1/"Bandwidth Per Pixel Phase Encode", stored in
% DICOM tag (0019, 1028) --> 63 ms

%%
clear;
clc;

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<NUSED>

%  Folders definitions
StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';

for iSub = NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    cd(fullfile(SubDir));

    % identify the number of sessions
    SesLs = dir('ses*');
    NbSes = numel(SesLs);

    %% Identify the first image of the first run
    TargetFile = spm_select('FPList', fullfile(SubDir, SesLs(1).name, 'func'), ...
                            ['^' SubLs(iSub).name '_ses-1_task-audiovisualtactile_run-01_bold.nii$']);
    if ~exist(TargetFile, 'file')
        try % unzip the first image if it is zipped
            fprintf(' Trying to unzip target image\n');
            gunzip(spm_select('FPList', fullfile(SubDir, SesLs(1).name, 'func'), ...
                              ['^' SubLs(iSub).name '_ses-1_task-audiovisualtactile_run-01_bold.nii.gz$']));
            TargetFile = spm_select('FPList', fullfile(SubDir, SesLs(1).name, 'func'), ...
                                    ['^' SubLs(iSub).name '_ses-1_task-audiovisualtactile_run-01_bold.nii$']);
        catch
            error('It seems that we are missing the reference image');
        end
    end

    %% DEFINES BATCH
    matlabbatch = {};

    RunInd = 1;
    for iSes = 1:NbSes % for each session

        cd(fullfile(SubDir, SesLs(iSes).name, 'fmap'));

        %% Coregister to the first image of the first run
        MagImg = spm_select('FPList', pwd, '^sub.*\magnitude.nii$');
        if ~exist(MagImg, 'file')
            try % unzip if zipped
                fprintf(' Trying to unzip magnitude image\n');
                gunzip(spm_select('FPList', pwd, '^.*\magnitude.nii.gz$'));
                MagImg = spm_select('FPList', pwd, '^.*\magnitude.nii$');
            catch
                error('Magnitude image is missing');
            end
        end
        matlabbatch{end + 1}.spm.spatial.coreg.estimate.source{1} = [MagImg ',1']; %#ok<*SAGROW>

        matlabbatch{end}.spm.spatial.coreg.estimate.ref{1} = [TargetFile ',1'];

        PhsImg = spm_select('FPList', pwd, '^sub.*\phasediff.nii$');
        if ~exist(PhsImg, 'file')
            try % unzip if zipped
                fprintf(' Trying to unzip phase image\n');
                gunzip(spm_select('FPList', pwd, '^.*\phasediff.nii.gz$'));
                PhsImg = spm_select('FPList', pwd, '^.*\phasediff.nii$');
            catch
                error('Phase difference image is missing');
            end
        end
        matlabbatch{end}.spm.spatial.coreg.estimate.other{1} = PhsImg;

        matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [8 4 2 1];
        matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = ...
            [repmat(0.001, 1, 3), repmat(0.0005, 1, 3), repmat(0.005, 1, 3), repmat(0.0005, 1, 3)];
        matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

        %% Batch to create VDM
        matlabbatch{end + 1}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.tert = 63;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.phase{1} = PhsImg;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.magnitude{1} = [MagImg ',1'];

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.session.epi{1} = [TargetFile ',1'];

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.et = [6 7.02];

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.maskbrain = 0;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.blipdir = -1;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.epifm = 0;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.ajm = 0;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.uflags.method = 'Mark3D';
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.uflags.fwhm = 10;
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.uflags.pad = 0;
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.uflags.ws = 1;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.mflags.template = ...
            {fullfile(spm('Dir'), 'toolbox', 'templates', 'T1.nii')};
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.mflags.fwhm = 5;
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.mflags.nerode = 2;
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.mflags.ndilate = 4;
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.mflags.thresh = .5;
        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsval.mflags.reg = .02;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.matchvdm = 0;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.sessname = 'session';

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.writeunwarped = 0;

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.anat = '';

        matlabbatch{end}.spm.tools.fieldmap.presubphasemag.subj.matchanat = 0;

    end

    %% Saves and run the batch
    cd(fullfile(SubDir));
    save (strcat('Create_VDM_Subj_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch.mat'), ...
          'matlabbatch');

    spm_jobman('run', matlabbatch);

    cd (StartDir);

end
