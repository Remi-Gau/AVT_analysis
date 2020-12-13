function PlotGMatrixAndSetAxis(Matrix, CondNames, Title, FONTSIZE, SymmetricalClim)
    
    if nargin < 5 || isempty(SymmetricalClim)
        SymmetricalClim = true;
    end
    
    % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
    H = 1;
    
    Matrix = H * Matrix * H';
    Clim = ComputeClimMatrix(Matrix, SymmetricalClim);
    imagesc(Matrix, Clim);
    
    SetAxisGMatrix(CondNames, FONTSIZE);
    
    t = title(Title);
    set(t, 'fontsize', FONTSIZE);
    
end