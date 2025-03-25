close
clear

load('data/training_data.mat', 'trainData');
load('data/testing_data.mat', 'testData');

maxFeatures = size(trainData, 2) - 1;
featureSteps = 5:5:maxFeatures;
numRows = length(featureSteps);

results = table('Size', [numRows, 5], ...
    'VariableTypes', repmat({'double'}, 1, 5), ...
    'VariableNames', {'numFeatures', 'DecisionTree', 'KNN', 'Bayes', 'SVM'});

results.numFeatures = featureSteps';
count = 1;

for i = 5:5:(size(trainData, 2)-1)
  [sub_train, sub_test, feat_names] = select_top_features(trainData, testData, i);
  fprintf("Sono state selezionate le migliori %d features:\n", i);
  disp(feat_names');
  tree = fitctree(sub_train, 'Label');
  knn = fitcknn(sub_train, 'Label');
  bayes = fitcnb(sub_train, 'Label');
  svm = fitcecoc(sub_train, 'Label');

  treePred = predict(tree, sub_test);
  knnPred = predict(knn, sub_test);
  bayesPred = predict(bayes, sub_test);
  svmPred = predict(svm, sub_test);

  f1_tree = compute_f1_score(sub_test.Label, treePred);
  f1_knn = compute_f1_score(sub_test.Label, knnPred);
  f1_bayes = compute_f1_score(sub_test.Label, bayesPred);
  f1_svm = compute_f1_score(sub_test.Label, svmPred);

  fprintf("F1 score per decision tree: %d \n", f1_tree);
  fprintf("F1 score per knn: %d \n", f1_knn);
  fprintf("F1 score per bayes: %d \n", f1_bayes);
  fprintf("F1 score per svm: %d \n", f1_svm);
  fprintf("-------------------------------------------------------\n\n");
  
  % results.features(count) = {feat_names};
  results.DecisionTree(count) = f1_tree;
  results.KNN(count) = f1_knn;
  results.Bayes(count) = f1_bayes;
  results.SVM(count) = f1_svm;

  count = count + 1;
end
