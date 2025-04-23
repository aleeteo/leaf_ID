function [C, confusion_matrix, f1_score] = test_svm_recognizer(training_data, testing_data, feature_number, saveFlag)
  arguments
    training_data table
    testing_data table
    feature_number double {mustBeInteger} = 25
    saveFlag logical = false
  end

  % Etichette assegnate: tutte le istanze di training sono "leaf"
  training_data.Label = repmat(categorical("leaf"), height(training_data), 1);

  % Rimappa le etichette numeriche in 'leaf' e 'unknown'
  numeric_labels = double(testing_data.Label);  % converte categorical → double
  mapped_labels = repmat("leaf", height(testing_data), 1);
  mapped_labels(numeric_labels == 11) = "unknown";
  testing_data.Label = categorical(mapped_labels);

  % Selezione delle feature più importanti
  [sub_train, sub_test, feat_names] = select_top_features(training_data, testing_data, feature_number);
  save('data/sel_features.mat', 'feat_names');

  % Addestra una One-Class SVM su sole foglie
  C = fitcsvm(sub_train(:, feat_names), ...
              ones(height(sub_train), 1), ...
              'KernelFunction', 'rbf', ...
              'Standardize', true, ...
              'OutlierFraction', 0.05);

  % Predizione su test set
  [pred, ~ ] = predict(C, sub_test(:, feat_names));

  % Conversione: da 1/-1 a categorie "leaf"/"unknown"
  pred_label = repmat("unknown", size(pred));
  pred_label(pred == 1) = "leaf";
  pred_label = categorical(pred_label);

  % Calcolo della matrice di confusione e F1 score
  confusion_matrix = confusionmat(sub_test.Label, pred_label);
  f1_score = compute_f1_score(sub_test.Label, pred_label);

  % Output a schermo
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(confusion_matrix);

  if saveFlag
    save('data/svm_model_recognizer.mat', 'C');
    fprintf('Modello salvato in data/svm_model_recognizer.mat\n');
  end
end
