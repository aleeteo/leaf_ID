function plot_scaling_accuracy(class_struct, unknown_struct, opts)
% Valuta e confronta le accuracy di classificazione e riconoscimento
% per dati raw, normalizzati e standardizzati. Salva i dati su CSV se richiesto.

  arguments
    class_struct
    unknown_struct
    opts.SaveData (1,1) logical = false
  end

  % Estrazione dati RAW
  [train_raw, test_raw, ~, train_unk_raw, test_unk_raw] = ...
    extract_data(class_struct, unknown_struct, ...
                'Scaling', 'none', ...
                'DoParallel', false);

  % Normalize
  [train_norm, scaling_data_norm] = normalize_features(train_raw);
  test_norm = normalize_features(test_raw, scaling_data_norm);
  train_unk_norm = normalize_features(train_unk_raw, scaling_data_norm);
  test_unk_norm = normalize_features(test_unk_raw, scaling_data_norm);

  % Standardize
  [train_std, scaling_data_std] = standardize_features(train_raw);
  test_std = standardize_features(test_raw, scaling_data_std);
  train_unk_std = standardize_features(train_unk_raw, scaling_data_std);
  test_unk_std = standardize_features(test_unk_raw, scaling_data_std);

  % Container per risultati
  classifier_acc = zeros(1,3);
  detector_acc   = zeros(1,3);

  % RAW
  [~, classifier_acc(1), ~, ~] = train_knn_classifier(train_raw, test_raw, ...
      NumFeatRange=[22, 28], NumNeighbors=5, ...
      VisualizeResults=false, SaveFlag=false);
  [~, detector_acc(1), ~] = train_detector(train_raw, test_raw, ...
      train_unk_raw, test_unk_raw, ...
      NumFeatRange=[18,20]);

  % NORMALIZE
  [~, classifier_acc(2), ~, ~] = train_knn_classifier(train_norm, test_norm, ...
      NumFeatRange=[22,28], NumNeighbors=5, ...
      VisualizeResults=false, SaveFlag=false);
  [~, detector_acc(2), ~] = train_detector(train_norm, test_norm, ...
      train_unk_norm, test_unk_norm, ...
      NumFeatRange=[18,20]);

  % STANDARDIZE
  [~, classifier_acc(3), ~, ~] = train_knn_classifier(train_std, test_std, ...
      NumFeatRange=[22,28], NumNeighbors=5, ...
      VisualizeResults=false, SaveFlag=false);
  [~, detector_acc(3), ~] = train_detector(train_std, test_std, ...
      train_unk_std, test_unk_std, ...
      NumFeatRange=[18,20]);

  % Plot
  labels = {'Raw', 'Normalized', 'Standardized'};
  data = [classifier_acc; detector_acc]';

  figure;
  bar(data);
  set(gca, 'XTickLabel', labels);
  legend({'Classifier', 'Detector'}, 'Location', 'northwest');
  ylabel('Accuracy');
  title('Accuracy confronto: Raw vs Normalize vs Standardize');
  grid on;

  % Esportazione dati se richiesto
  if opts.SaveData
    if ~exist('plots', 'dir')
      mkdir('plots');
    end
    T = table(labels', classifier_acc', detector_acc', ...
              'VariableNames', {'Condition', 'Classifier', 'Detector'});
    writetable(T, fullfile('plots', 'scaling_accuracy.csv'));
  end
end
