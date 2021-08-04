% (C) Copyright 2021 Remi Gau

clear;

ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

tmp  = linspace(0, 1, 12);
ExProba = {reshape(tmp, 4, 3)'};

Fam{1}{1}.names = 'family names';

Analysis.name = 'test';

CreateFigureExceedanceProba(ExProba, Fam, Analysis, 'Cst', 'test', pwd, ROIs);
