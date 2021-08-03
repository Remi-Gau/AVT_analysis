function [PVAL, F, DF1, DF2] = FTestAndPrint(model, c, message, fid)

    fprintf(1, '\n');

    pattern.screen = '%s\t F(%i,%i)= %f\t p = %f\n';
    pattern.file = '%s\n\tF(%i,%i)=%.3f\t%s\n';

    [PVAL, F, DF1, DF2] = coefTest(model.lme, c);

    fprintf(fid, pattern.screen, ...
            message, ...
            DF1, DF2, ...
            F, PVAL);

    fprintf(1, 'Contrast: \n');
    disp(c);

end
