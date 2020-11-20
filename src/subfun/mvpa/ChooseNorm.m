function [opt] = ChooseNorm(Norm, opt)

    switch Norm
        case 1
            opt.scaling.img.eucledian = 1;
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 0;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 1;
        case 2
            opt.scaling.img.eucledian = 1;
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 0;
            opt.scaling.feat.range = 1;
            opt.scaling.feat.sessmean = 0;
        case 3
            opt.scaling.img.eucledian = 1;
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 1;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 0;
        case 4
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 0;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 1;
        case 5
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 0;
            opt.scaling.feat.range = 1;
            opt.scaling.feat.sessmean = 0;
        case 6
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 1;
            opt.scaling.feat.mean = 1;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 0;
        case 7
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 1;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 0;
        case 8
            opt.scaling.img.eucledian = 0;
            opt.scaling.img.zscore = 0;
            opt.scaling.feat.mean = 0;
            opt.scaling.feat.range = 0;
            opt.scaling.feat.sessmean = 0;
    end

end
