function C = test_knn(training_data, testing_data, feature_number, k)
  arguments
    training_data table
    testing_data table
    feature_number double {isinteger} = 25
    k double {isinteger} = 1
  end

  [sub_train, sub_test, feat_names] = select_top_features(training_data, testing_data, feature_number);
  save('data/sel_features.mat', 'feat_names');

  C = fitcknn(sub_train, 'Label', 'NumNeighbors', k, 'Standardize', true);
  % C = fitcknn(sub_train, 'Label', 'NumNeighbors', k);

  pred = predict(C, sub_test);

  confusion_matrix = confusionmat(sub_test.Label, pred);
  f1_score = compute_f1_score(sub_test.Label, pred);
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(abs(confusion_matrix));
end
