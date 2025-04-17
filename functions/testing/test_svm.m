function C = test_svm(training_data, testing_data, feature_number, saveFlag)
  arguments
    training_data table
    testing_data table
    feature_number double {isinteger} = 25
    saveFlag logical = false
  end

  [sub_train, sub_test, feat_names] = select_top_features(training_data, testing_data, feature_number);
  save('data/sel_features.mat', 'feat_names');

  % C = fitcknn(sub_train, 'Label', 'NumNeighbors', k, 'optimizeHyperparameters', 'auto');
  C = fitcecoc(sub_train, 'Label', 'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
              struct('AcquisitionFunctionName', 'expected-improvement-plus'));


  pred = predict(C, sub_test);

  confusion_matrix = confusionmat(sub_test.Label, pred);
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
