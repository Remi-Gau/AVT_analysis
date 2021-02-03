% (C) Copyright 2020 Remi Gau

function ProfileLine = GetProfileLinePlotParameters()

    ProfileLine.LineColor = 'k';
    ProfileLine.LineWidth = 2.5;
    ProfileLine.ErrorLineWidth = 1;
    ProfileLine.LineStyle = '-';
    ProfileLine.Marker = 'o';
    ProfileLine.MarkerSize = 2;
    ProfileLine.MarkerFaceColor = ProfileLine.LineColor;
    ProfileLine.Transparent = true;

end
