function SVM = reorganize_mvpa_results(SVM, TEMP, NbRuns2Incl, RunSubSamp, iPerm)

  for iCV = 1:size(TEMP, 1)
    
    results = TEMP(iCV, 1).results;
    acc = mean(results{1}.pred == results{1}.label);
    
    SVM.ROI.run(NbRuns2Incl).rand(RunSubSamp).perm(iPerm).CV(iCV, 1).results = results;
    SVM.ROI.run(NbRuns2Incl).rand(RunSubSamp).perm(iPerm).CV(iCV, 1).acc = acc;
    
    if isfield(TEMP, 'layers')
      
      for iLayer = 1:size(TEMP(iCV, 1).layers, 1)
      
      results = TEMP(iCV, 1).layers(iLayer, 1).results;
      acc = mean(results.pred == results.label);
      
      SVM.ROI.run(NbRuns2Incl).rand(RunSubSamp).perm(iPerm).CV(iCV, 1).layers(iLayer, 1).results = results;
      SVM.ROI.run(NbRuns2Incl).rand(RunSubSamp).perm(iPerm).CV(iCV, 1).layers(iLayer, 1).acc = acc;
      
      end
      
    end
    
  end
  
end