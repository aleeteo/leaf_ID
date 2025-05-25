function plot_scaling_accuracy(class_struct, unknown_struct)
% Valuta l'impatto dello scaling (nessuno, normalizzazione, standardizzazione)
% su accuratezza di classificazione e riconoscimento.

  scalings = ["none", "normalize", "standardize"];
  nScalings = numel(scalings);
  maxFeat = 25; % oppure size dinamico se vuoi adattarlo
  acc_classifier = zeros(maxFeat, nScalings);
  acc_detector = zeros(maxFeat, nScalings);

  for s = 1:nScalings
    scaling = scalings(s);

    % Estrazione dati senza scaling
    [train_raw, test_raw, ~, train_unk_raw, test_unk_raw] = ...
      extract_data(class_struct, unknown_struct, Scaling="none", ...
                    log=false, DoParallel=true, saveFlag=false);

    % Applico lo scaling manualmente
    switch scaling
      case "normalize"
        [train, scaling_data] = normalize_features(train_raw);
        test = normalize_features(test_raw, scaling_data);
        train_unk = normalize_features(train_unk_raw, scaling_data);
        test_unk = normalize_features(test_unk_raw, scaling_data);
      case "standardize"
        [train, scaling_data] = standardize_features(train_raw);
        test = standardize_features(test_raw, scaling_data);
        train_unk = standardize_features(train_unk_raw, scaling_data);
        test_unk = standardize_features(test_unk_raw, scaling_data);
      case "none"
        train = train_raw;
        test = test_raw;
        train_unk = train_unk_raw;
        test_unk = test_unk_raw;
    end

    % Accuracy classificatore
    for i = 1:maxFeat
      [~, acc, ~, ~] = train_knn_classifier(train, test, ...
        NumFeatRange=[i, i], NumNeighbors=3, ...
        VisualizeResults=false, SaveFlag=false);
      acc_classifier(i, s) = acc;
    end

    % Accuracy riconoscitore
    for i = 1:maxFeat
      [~, acc, ~] = train_detector(train, test, train_unk, test_unk, ...
        NumFeatRange=[i, i]);
      acc_detector(i, s) = acc;
    end
  end

  % === PLOT ===
  figure;
  hold on;
  styles = {'o-', 's--', 'd-.'};
  for s = 1:nScalings
    plot(1:maxFeat, acc_classifier(:,s), styles{s}, 'DisplayName', sprintf("Classifier (%s)", scalings(s)));
  end
  ylabel('Accuracy');
  xlabel('Number of Features');
  title('Classifier accuracy by scaling');
  legend show;
  grid on;

  figure;
  hold on;
  for s = 1:nScalings
    plot(1:maxFeat, acc_detector(:,s), styles{s}, 'DisplayName', sprintf("Detector (%s)", scalings(s)));
  end
  ylabel('Accuracy');
  xlabel('Number of Features');
  title('Detector accuracy by scaling');
  legend show;
  grid on;
end
