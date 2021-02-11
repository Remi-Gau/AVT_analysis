% (C) Copyright 2020 Remi Gau

function ProfileLine = GetProfileLinePlotParameters()

    ProfileLine.LineColor = 'k';
    ProfileLine.LineWidth = 3;
    ProfileLine.ErrorLineWidth = 2;
    ProfileLine.LineStyle = '-';
    ProfileLine.Marker = 'o';
    ProfileLine.MarkerSize = 8;
    ProfileLine.MarkerFaceColor = ProfileLine.LineColor;
    ProfileLine.Transparent = true;

end
