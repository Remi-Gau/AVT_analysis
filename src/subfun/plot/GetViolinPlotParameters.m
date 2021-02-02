% (C) Copyright 2020 Remi Gau

function [ViolinPlotParameters, MeanDispersion] = GetViolinPlotParameters()

    ViolinPlotParameters.DistWidth = 0.5;
    ViolinPlotParameters.ShowMeanMedian = 0;
    ViolinPlotParameters.GlobalNorm = 2;
    
    ViolinPlotParameters.Marker = 'o';
    ViolinPlotParameters.MarkerSize = 2;
    ViolinPlotParameters.MarkerEdgeColor = 'k';
    ViolinPlotParameters.MarkerFaceColor = 'k';
    
    ViolinPlotParameters.LineWidth = 1;
    ViolinPlotParameters.BinWidth = 0.5;
    ViolinPlotParameters.SpreadWidth = 0.8;
    
    ViolinPlotParameters.Margin = 3.5;
    
    MeanDispersion.LineWidth = 1;
    MeanDispersion.Marker = 'o';
    MeanDispersion.MarkerSize = 5;

end

