function opt = choose_norm(opt, Norm)

    opt.scaling.img.eucledian = false;
    opt.scaling.img.zscore = false;
    opt.scaling.feat.mean = false;
    opt.scaling.feat.range = false;
    opt.scaling.feat.sessmean = false;

    switch Norm
        case 1
            opt.scaling.img.type = 'Eucl';
            opt.scaling.feat.type = 'SesMeanCent';
        case 2
            opt.scaling.img.type = 'Eucl';
            opt.scaling.feat.type = 'none';
        case 3
            opt.scaling.img.type = 'Eucl';
            opt.scaling.feat.type = 'Mean';
        case 4
            opt.scaling.img.type = 'ZScore';
            opt.scaling.feat.type = 'SesMeanCent';
        case 5
            opt.scaling.img.type = 'ZScore';
            opt.scaling.feat.type = 'Range';
        case 6
            opt.scaling.img.type = 'ZScore';
            opt.scaling.feat.type = 'Mean';
        case 7
            opt.scaling.img.type = 'none';
            opt.scaling.feat.type = 'Mean';
        case 8
            opt.scaling.img.type = 'none';
            opt.scaling.feat.type = 'none';
    end

    switch opt.scaling.img.type
        case 'Eucl'
            opt.scaling.img.eucledian = true;

        case 'ZScore'
            opt.scaling.img.zscore = true;

        otherwise
    end

    switch opt.scaling.feat.type
        case 'Mean'
            opt.scaling.feat.mean = true;

        case 'Range'
            opt.scaling.feat.range = true;

        case 'SesMeanCent'
            opt.scaling.feat.sessmean = true;

        otherwise
    end

end
