function [classifier, test_accuracy] = test_classification(training_data, testing_data, options)
  arguments
    training_data table
    testing_data table
    options.saveFlag (1,1) logical = false
    options.model (1,1) string {mustBeMember(options.model, ["svm", "tree", "knn", "bayes", "ensamble", "auto"])} = "svm"
    options.optimize (1,1) {mustBeNumericOrLogical} = false
  end

  if options.optimize 
    optimize='auto'; 
  else 
    optimize='none'; 
  end

  switch options.model
    case 'svm'
      classifier = fitcecoc(training_data, 'Label', 'OptimizeHyperparameters', optimize);
    case 'tree'
      classifier = fitctree(training_data, 'Label', 'OptimizeHyperparameters', optimize);
    case 'knn'
      classifier = fitcknn(training_data, 'Label', 'OptimizeHyperparameters', optimize);
    case 'bayes'
      classifier = fitcnb(training_data, 'Label', 'OptimizeHyperparameters', optimize);
    case 'ensamble'
      classifier = fitcensemble(training_data, 'Label', 'Method', 'Bag', 'OptimizeHyperparameters', optimize);
    case 'auto'
      classifier = fitcauto(training_data, 'Label', 'OptimizeHyperparameters', optimize);
    otherwise
      error('Invalid model type. Choose from svm, tree, knn, or bayes.');
  end
  
  pred = predict(classifier, testing_data);

  confusion_matrix = confusionmat(testing_data.Label, pred);
  test_accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:));
  f1_score = compute_f1_score(testing_data.Label, pred);
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(abs(confusion_matrix));

  if options.saveFlag
    % Save the model to a file
    modelFileName = 'data/classifier.mat';
    save(modelFileName, 'classifier', 'test_accuracy');
    fprintf('Model saved to %s\n', modelFileName);
  end
end
