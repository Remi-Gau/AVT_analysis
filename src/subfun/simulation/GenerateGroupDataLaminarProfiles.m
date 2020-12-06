% (C) Copyright 2020 Remi Gau
function [Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt)
    %
    % generate data to be used for BOLD / MVPA lamniar profile plotting
    %
    % USAGE::
    %
    %  [Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt)
    %
    % :param Opt:
    % :type Opt: structure
    %
    %   - ``Opt.NbSubject`` = 2
    %   - ``Opt.NbRuns`` = 4
    %   - ``Opt.Betas = [Cst; Lin; Quad]``
    %   - ``Opt.StdDevBetweenSubject`` is the between subject variance (betas of the laminar mode are
    %     assumed indenpendent)
    %   - ``Opt.StdDevWithinSubject`` is the within subject variance (runs are
    %     assumed indenpendent)
    %   - ``Opt.NbLayers``
    %
    % :returns:
    %           :Data: (array) m X n with m = NbSubject * NbRuns and n = NbLayers
    %           :SubjectVec: (vertical vector)
    %
    % EXAMPLE::
    %
    %   Cst = 1;
    %   Lin = 0.5;
    %   Quad = 0.1;
    %
    %   Opt.NbSubject = 2;
    %   Opt.NbRuns = 4;
    %   Opt.Betas = [Cst; Lin; Quad];
    %   Opt.StdDevBetweenSubject = 0.1;
    %   Opt.StdDevWithinSubject = 0.1;
    %   Opt.NbLayers = 6;
    %
    %   [Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt);
    %

    DesMat = SetDesignMatLamGlm(Opt.NbLayers, true);

    % Set beta values for the subjects with some noise
    Betas = repmat(Opt.Betas, 1, Opt.NbSubject);
    Betas = Betas + randn(size(Betas)) * Opt.StdDevBetweenSubject;

    SubjectVec = 1:Opt.NbSubject;

    % Set beta values for the runs of the subjects
    Betas = repmat(Betas, 1, Opt.NbRuns);
    Betas = Betas + randn(size(Betas)) * Opt.StdDevWithinSubject;

    SubjectVec = repmat(SubjectVec, 1, Opt.NbRuns);

    Data = DesMat * Betas;

    Data =  Data';

    [SubjectVec, Idx] =  sort(SubjectVec'); %#ok<TRSRT>

    Data = Data(Idx, :);

end
