function [pred, acc, cm] = classify_multiple(img, mask, classifier, detector, scaling_data, options)
%CLASSIFY_MULTIPLE Classifica gli oggetti segmentati in un'immagine.
%
%   [pred, acc, cm] = classify_multiple(img, mask, classifier, detector, scaling_data, options)
%
%   INPUT:
%     img         - Immagine RGB (uint8)
%     mask        - Maschera binaria con oggetti segmentati
%     classifier  - Modello di classificazione finale
%     detector  - Modello di riconoscimento (es. unknowns)
%     scaling_data- Struct con parametri di normalizzazione o standardizzazione
%     options     - Struttura con campi opzionali:
%         .labels        - Matrice di label ground truth (stessa size di img/mask)
%         .standardize   - true = z-score, false = [0,1] (default: true)
%         .DoParallel   - true = usa parfor, false = for (default: false)
%
%   OUTPUT:
%     pred - Maschera con le etichette assegnate (interi)
%     acc  - Accuratezza sulle regioni se disponibili le label (altrimenti [])
%     cm   - Confusion matrix sulle regioni se disponibili le label (altrimenti [])

  arguments
    img (:, :, 3) uint8
    mask (:, :) logical
    classifier
    detector
    scaling_data
    options.labels (:,:) = []
    options.standardize (1,1) logical = true
    options.DoParallel (1,1) logical = false
  end

  standardize = options.standardize;
  DoParallel = options.DoParallel;

  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  class_names = classifier.PredictorNames;
  rec_names   = detector.PredictorNames;

  labels = zeros(1, num_labels);

  if DoParallel && isempty(gcp('nocreate'))
    parpool;
  end

  if DoParallel
    parfor i = 1:num_labels
      item_mask = comps == i;
      labels(i) = classify_object(img, item_mask, classifier, detector, class_names, rec_names, scaling_data, standardize);
    end
  else
    for i = 1:num_labels
      item_mask = comps == i;
      labels(i) = classify_object(img, item_mask, classifier, detector, class_names, rec_names, scaling_data, standardize);
    end
  end

  % Ricostruzione maschera finale
  for i = 1:num_labels
    pred(comps == i) = labels(i);
  end

  % Calcolo accuracy e confusion matrix se disponibili le label
  acc = [];
  cm  = [];
  if ~isempty(options.labels)
    true_labels = zeros(1, num_labels);
    for i = 1:num_labels
      region_pixels = options.labels(comps == i);
      region_pixels = region_pixels(region_pixels > 0);  % ignora background
      if isempty(region_pixels)
        true_labels(i) = 0;
      else
        true_labels(i) = mode(region_pixels);
      end
    end

    valid_idx = true_labels > 0;
    true_valid = true_labels(valid_idx);
    pred_valid = labels(valid_idx);

    acc = mean(true_valid == pred_valid);
    cm  = confusionmat(true_valid, pred_valid);
  end
end

function label = classify_object(img, item_mask, classifier, detector, class_names, rec_names, scaling_data, standardize)
%CLASSIFY_OBJECT Classifica un singolo oggetto usando riconoscitore e classificatore

  desc = compute_descriptors(img, item_mask);
  if standardize
    desc = standardize_features(desc, scaling_data);
  else
    desc = normalize_features(desc, scaling_data);
  end

  % Fase 1: riconoscimento unknown
  rec_features = desc(:, rec_names);
  rec_pred = detector.predict(rec_features);

  if rec_pred == 0
    label = 11;  % unknown
    return;
  end

  % Fase 2: classificazione della foglia
  class_features = desc(:, class_names);
  label = predict(classifier, class_features);
end
