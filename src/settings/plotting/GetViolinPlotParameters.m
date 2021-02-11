% (C) Copyright 2020 Remi Gau

function [ViolinPlotParameters, MeanDispersion] = GetViolinPlotParameters()

    ViolinPlotParameters.DistWidth = 0.7;
    ViolinPlotParameters.ShowMeanMedian = 0;
    ViolinPlotParameters.GlobalNorm = 2;

    ViolinPlotParameters.Marker = 'o';
    ViolinPlotParameters.MarkerSize = 7;
    ViolinPlotParameters.MarkerEdgeColor = 'k';
    ViolinPlotParameters.MarkerFaceColor = 'w';

    ViolinPlotParameters.LineWidth = 2;
    ViolinPlotParameters.BinWidth = 1;
    ViolinPlotParameters.SpreadWidth = 0.8;

    ViolinPlotParameters.Margin = 4.5;

    MeanDispersion.LineWidth = 1;
    MeanDispersion.Marker = 'o';
    MeanDispersion.MarkerSize = 5;

end
