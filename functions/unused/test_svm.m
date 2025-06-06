function [classifier, accuracy, feat_names] = test_svm(training_data, testing_data, options)
  arguments
    training_data table
    testing_data table
    options.feature_number (1,1) double {mustBeNonnegative} = 0
    options.SaveFlag (1,1) logical = false
  end
  feature_number = options.feature_number;
  SaveFlag = options.SaveFlag;

  if feature_number == 0
    sub_train = training_data;
    sub_test = testing_data;
    feat_names = training_data.Properties.VariableNames;
  else 
    [sub_train, sub_test, feat_names] = select_top_features(training_data, testing_data, feature_number);
    save('data/sel_features.mat', 'feat_names');
  end

  % C = fitcknn(sub_train, 'Label', 'NumNeighbors', k, 'optimizeHyperparameters', 'auto');
  classifier = fitcecoc(sub_train, 'Label', 'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
              struct('AcquisitionFunctionName', 'expected-improvement-plus'));


  pred = predict(classifier, sub_test);

  confusion_matrix = confusionmat(sub_test.Label, pred);
  accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:));
  f1_score = compute_f1_score(sub_test.Label, pred);
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(abs(confusion_matrix));

  if SaveFlag
    % Save the model to a file
    modelFileName = 'data/classifier.mat';
    save(modelFileName, 'classifier');
    fprintf('Model saved to %s\n', modelFileName);
  end
end
