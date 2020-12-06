% (C) Copyright 2020 Remi Gau

Cst = 1;
Lin = 0.5;
Quad = 0.1;

Opt.NbSubject = 2;
Opt.NbRuns = 4;
Opt.Betas = [Cst; Lin; Quad];
Opt.StdDevBetweenSubject = 0.2;
Opt.StdDevWithinSubject = 0.2;
Opt.NbLayers = 6;

[Data, SubjectVec] = GenerateGroupDataLaminarProfiles(Opt)

betaHat = RunLaminarGlm(Data)

[GroupData] = ComputeSubjectAverage(Data, SubjectVec)
[GroupDetaHatData, SubjectVec] = ComputeSubjectAverage(betaHat, SubjectVec)
