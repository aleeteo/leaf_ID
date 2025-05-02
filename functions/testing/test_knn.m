function C = test_knn(training_data, testing_data, options)
  arguments
    training_data table
    testing_data table
    % feature_number double {isinteger} = 25
    % k double {isinteger} = 1
    % saveFlag logical = false
    options.feature_number (1,1) double {mustBeInteger} = 0
    options.k (1,1) double {mustBeInteger} = 1
    options.optimizeHyperparameters logical = true
    options.saveFlag logical = false
  end

  feature_number = options.feature_number;
  k = options.k;
  if options.optimizeHyperparameters
    optimizeHyperparameters = 'auto';
  else
    optimizeHyperparameters = 'none';
  end
  saveFlag = options.saveFlag;

  [sub_train, sub_test, feat_names] = select_top_features(training_data, testing_data, feature_number);
  save('data/sel_features.mat', 'feat_names');

  C = fitcknn(sub_train, 'Label', 'NumNeighbors', k, 'optimizeHyperparameters', optimizeHyperparameters);


  pred = predict(C, sub_test);

  confusion_matrix = confusionmat(sub_test.Label, pred);
  f1_score = compute_f1_score(sub_test.Label, pred);
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(abs(confusion_matrix));

  if saveFlag
    % Save the model to a file
    modelFileName = 'data/knn_model.mat';
    save(modelFileName, 'C');
    fprintf('Model saved to %s\n', modelFileName);
  end
end
