function Clim = ComputeClimMatrix(Matrix, SymmetricalClim)
    
    if nargin < 2 || isempty(SymmetricalClim)
        SymmetricalClim = true;
    end
    
    Min = min(Matrix(:));
    Max = max(Matrix(:));
    
    if Min > 0
        Min = 0;
    end
    if Max < 0
        Max = 0;
    end
    
    Clim = [Min, Max];
    if SymmetricalClim
        MinMax = max(abs([Min, Max]));
        Clim = [MinMax * -1, MinMax];
    end
    
end