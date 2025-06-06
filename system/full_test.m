function full_test(options)
  arguments
    options.Classifier (1,1) string {mustBeMember(options.Classifier, ...
                                  {'ensemble', 'knn', 'bayesian'})} = 'knn'
    options.SaveFlag (1,1) logical = false
  end
  fprintf("caricamento dati...\n");
  load("data/data.mat", "training_data", "scaling_data");
  fprintf("totale features estratte: %d \n", size(training_data, 2) - 1);
  clear training_data
  fprintf("\n ---------------------------\n");

  switch options.Classifier
    case 'ensemble'
      fprintf("caricamento classifier ensamble... \n")
      load("data/e_classifier.mat", "classifier", "test_accuracy");
    case 'knn'
      fprintf("caricamento classifier knn... \n")
      load("data/classifier.mat", "classifier", "test_accuracy");
    case 'bayesian'
      fprintf("caricamento classifier bayesiano... \n")
      load("data/b_classifier.mat", "classifier", "test_accuracy");
  end
  fprintf("accuracy del classifier sul test set: %.2f%%\n", test_accuracy * 100);
  fprintf("numero di features selezionate: %d\n", size(classifier.PredictorNames, 2))
  fprintf("\n ---------------------------\n");

  fprintf("caricamento detector... \n")
  load("data/detector.mat", "detector", "test_accuracy");
  fprintf("accuracy del detector sul test set: %.2f%%\n", test_accuracy * 100);
  fprintf("numero di features selezionate: %d\n", size(detector.PredictorNames, 2))
  fprintf("\n ---------------------------\n");

  fprintf("testing su altre immagini...\n");
  % fprintf("testing su training e test set (basato su istanze)\n");
  % test_classify_image(classifier, detector, scaling_data, ...
  %                     directory="dataset/03_classes", ...
  %                     standardize=true, DoParallel=false, ...
  %                     visualize_predictions=false, ...
  %                     visualize_confmat=false);
  %
  % fprintf("\n ---------------------------\n");

  fprintf("testing su misc set\n");
  test_classify_image(classifier, detector, scaling_data, ...
                      directory="dataset/05_miscs", ...
                      standardize=true, DoParallel=false, ...
                      visualize_predictions=false, ...
                      visualize_confmat=false);
  fprintf("\n ---------------------------\n");

  fprintf("testing su unknown set\n");
  test_classify_image(classifier, detector, scaling_data, ...
                      directory="dataset/06_unknown_miscs", ...
                      standardize=true, doparallel=false, ...
                      visualize_predictions=false, ...
                      visualize_confmat=false);
  fprintf("\n ---------------------------\n");
end
