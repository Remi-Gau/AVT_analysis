function save_mvpa_results(OutputDir, opt, ClassAcc, SVM, NbLayers)

    SaveSufix = return_mvpa_suffix(opt, NbLayers);

    Filename = fullfile(OutputDir, [SVM.name '_ROI-' SVM.ROI.name SaveSufix]);

    fprintf('   Saving: %s\n\n', Filename);

    save(Filename, ...
         'SVM', 'opt', 'ClassAcc', ...
         '-v7.3');

end
