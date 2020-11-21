function print_PCM_table(Mat2Save, Mat2Save_struct, ROI, NbROI, save_dir, opt)
    for iROI = 1:NbROI
        ROI_name  = ROI(iROI).name;
        csv_file = fullfile(save_dir, ...
                            [ROI_name '_' opt.FigName  '.csv']);

        Mat2Save_struct.p_s = Mat2Save(:, 1, iROI);
        Mat2Save_struct.p_si = Mat2Save(:, 2, iROI);
        Mat2Save_struct.p_i = Mat2Save(:, 3, iROI);
        spm_save(csv_file, Mat2Save_struct);
    end
end
