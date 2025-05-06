function [C, accuracy, feat_names] = test_classification(training_data, testing_data, options)
  arguments
    training_data table
    testing_data table
    options.feature_number (1,1) double {mustBeNonnegative} = 0
    options.saveFlag (1,1) logical = false
    options.model (1,1) string {mustBeMember(options.model, ["svm", "tree", "knn", "bayes", "ensamble", "auto"])} = "svm"
    options.optimize (1,1) {mustBeNumericOrLogical} = false
  end

  feature_number = options.feature_number;
  saveFlag = options.saveFlag;

  if feature_number == 0
    sub_train = training_data;
    sub_test = testing_data;
    feat_names = training_data.Properties.VariableNames;
  else 
    [sub_train, sub_test, feat_names] = select_top_features(training_data, testing_data, feature_number);
    save('data/sel_features.mat', 'feat_names');
  end
  
  switch options.model
    case 'svm'
      C = fitcecoc(sub_train, 'Label');
    case 'tree'
      C = fitctree(sub_train, 'Label');
    case 'knn'
      C = fitcknn(sub_train, 'Label');
    case 'bayes'
      C = fitcnb(sub_train, 'Label');
    case 'ensamble'
      C = fitcensemble(sub_train, 'Label', 'Method', 'Bag');
    case 'auto'
      C = fitcauto(sub_train, 'Label', 'OptimizeHyperparameters', 'auto');
    otherwise
      error('Invalid model type. Choose from svm, tree, knn, or bayes.');
  end
  

  pred = predict(C, sub_test);

  confusion_matrix = confusionmat(sub_test.Label, pred);
  accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:));
  f1_score = compute_f1_score(sub_test.Label, pred);
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(abs(confusion_matrix));

  if saveFlag
    % Save the model to a file
    modelFileName = 'data/svm_model.mat';
    save(modelFileName, 'C');
    fprintf('Model saved to %s\n', modelFileName);
  end
end
