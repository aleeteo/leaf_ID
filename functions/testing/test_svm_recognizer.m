function [recognizer, confusion_matrix, f1_score] = test_svm_recognizer(training_data, testing_data, options)
  arguments
    training_data table
    testing_data table
    options.OutlierFraction {mustBeNumeric, mustBePositive} = 0.5
    options.saveFlag logical = false
  end

  % feature_number = options.feature_number;
  saveFlag = options.saveFlag;

  % Etichette assegnate: tutte le istanze di training sono "leaf"
  training_data.Label = repmat(categorical("leaf"), height(training_data), 1);

  % Rimappa le etichette numeriche in 'leaf' e 'unknown'
  numeric_labels = double(testing_data.Label);  % converte categorical → double
  mapped_labels = repmat("leaf", height(testing_data), 1);
  mapped_labels(numeric_labels == 11) = "unknown";
  testing_data.Label = categorical(mapped_labels);

  % Addestra una One-Class SVM su sole foglie
  recognizer = fitcsvm(training_data, ...
              ones(height(training_data), 1), ...
              'KernelFunction', 'rbf', ...
              'OutlierFraction', options.OutlierFraction);

  % Predizione su test set
  [pred, ~ ] = predict(recognizer, testing_data);

  % Conversione: da 1/-1 a categorie "leaf"/"unknown"
  pred_label = repmat("unknown", size(pred));
  pred_label(pred == 1) = "leaf";
  pred_label = categorical(pred_label);

  % Calcolo della matrice di confusione e F1 score
  confusion_matrix = confusionmat(testing_data.Label, pred_label);
  f1_score = compute_f1_score(testing_data.Label, pred_label);

  % Output a schermo
  fprintf('F1 Score: %f\n', f1_score);
  confusionchart(confusion_matrix);

  if saveFlag
    save('data/recognizer.mat', 'recognizer');
    fprintf('Modello salvato in data/svm_model_recognizer.mat\n');
  end
end
