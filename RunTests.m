% (C) Copyright 2019 Remi Gau

warning('OFF');

spm('defaults', 'fMRI');

folderToCover = fullfile(pwd, 'src');
testFolder = fullfile(pwd, 'tests');

fprintf(1, 'Running tests\n');

success = moxunit_runtests( ...
                           testFolder, ...
                           '-verbose', '-recursive', '-with_coverage', ...
                           '-cover', folderToCover, ...
                           '-cover_xml_file', 'coverage.xml', ...
                           '-cover_html_dir', fullfile(pwd, 'coverage_html'));

if success
    system('echo 0 > test_report.log');
else
    system('echo 1 > test_report.log');
end
