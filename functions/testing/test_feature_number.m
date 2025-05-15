function results = test_feature_number(training_data, testing_data)
  maxFeatures = size(training_data, 2) - 1;
  featureSteps = 5:5:maxFeatures;
  numRows = length(featureSteps);

  results = table('Size', [numRows, 6], ...
      'VariableTypes', repmat({'double'}, 1, 6), ...
      'VariableNames', {'numFeatures', 'DecisionTree', 'KNN', 'Bayes', 'SVM', 'Ensamble'});

  results.numFeatures = featureSteps';
  count = 1;

  for i = 5:5:(size(training_data, 2)-1)
    % [sub_train, sub_test, ~] = select_top_features(training_data, testing_data, i);
    bestSet = select_best_features(training_data, "Label", Verbose=true, NumFeatRange=[i, i], Importanza="oobPermuted");
    sub_train = training_data(:, [1 bestSet]);
    sub_test = testing_data(:, [1 bestSet]);

    tree = fitctree(sub_train, 'Label');
    knn = fitcknn(sub_train, 'Label');
    bayes = fitcnb(sub_train, 'Label');
    svm = fitcecoc(sub_train, 'Label');
    ensamble = fitcensemble(sub_train, 'Label');

    treePred = predict(tree, sub_test);
    knnPred = predict(knn, sub_test);
    bayesPred = predict(bayes, sub_test);
    svmPred = predict(svm, sub_test);
    ensamblePred = predict(ensamble, sub_test);

    f1_tree = compute_f1_score(sub_test.Label, treePred);
    f1_knn = compute_f1_score(sub_test.Label, knnPred);
    f1_bayes = compute_f1_score(sub_test.Label, bayesPred);
    f1_svm = compute_f1_score(sub_test.Label, svmPred);
    fq1_ensamble = compute_f1_score(sub_test.Label, ensamblePred);

    fprintf("F1 score per decision tree: %d \n", f1_tree);
    fprintf("F1 score per knn: %d \n", f1_knn);
    fprintf("F1 score per bayes: %d \n", f1_bayes);
    fprintf("F1 score per svm: %d \n", f1_svm);
    fprintf("F1 score per ensamble: %d \n", fq1_ensamble);
    fprintf("-------------------------------------------------------\n\n");
    
    % results.features(count) = {feat_names};
    results.DecisionTree(count) = f1_tree;
    results.KNN(count) = f1_knn;
    results.Bayes(count) = f1_bayes;
    results.SVM(count) = f1_svm;
    results.Ensamble(count) = fq1_ensamble;

    count = count + 1;
  end

  disp(results);
end
