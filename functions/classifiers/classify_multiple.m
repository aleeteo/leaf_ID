function pred = classify_multiple(img, mask, classifier, recognizer, scaling_data, options)
%CLASSIFY_MULTIPLE Classifica gli oggetti segmentati in un'immagine.
%
%   pred = classify_multiple(img, mask, classifier, recognizer, scaling_data, standardize, parallelize)
%
%   INPUT:
%     img         - Immagine RGB (uint8)
%     mask        - Maschera binaria con oggetti segmentati
%     classifier  - Modello di classificazione finale
%     recognizer  - Modello di riconoscimento (es. unknowns)
%     scaling_data- Struct con parametri di normalizzazione o standardizzazione
%     standardize - Booleano: true = z-score, false = [0,1]
%     parallelize - Booleano: true = usa parfor, false = usa for
%
%   OUTPUT:
%     pred - Maschera con le etichette assegnate (interi)

  arguments
    img (:, :, 3) uint8
    mask (:, :) logical
    classifier
    recognizer
    scaling_data
    options.standardize (1,1) logical = true
    options.parallelize (1,1) logical = false
  end
  standardize = options.standardize;
  parallelize = options.parallelize;

  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  class_names = classifier.PredictorNames;
  rec_names   = recognizer.PredictorNames;

  labels = zeros(1, num_labels);
  
  % Avvio automatico del pool se serve
  if parallelize && isempty(gcp('nocreate'))
    parpool;
  end

  if parallelize
    parfor i = 1:num_labels
      item_mask = comps == i;
      labels(i) = classify_object(img, item_mask, classifier, recognizer, class_names, rec_names, scaling_data, standardize);
    end
  else
    for i = 1:num_labels
      item_mask = comps == i;
      labels(i) = classify_object(img, item_mask, classifier, recognizer, class_names, rec_names, scaling_data, standardize);
    end
  end

  % Ricostruzione maschera finale
  for i = 1:num_labels
    pred(comps == i) = labels(i);
  end
end

function label = classify_object(img, item_mask, classifier, recognizer, class_names, rec_names, scaling_data, standardize)
%CLASSIFY_OBJECT Classifica un singolo oggetto usando riconoscitore e classificatore

  desc = compute_descriptors(img, item_mask);
  if standardize
    desc = standardize_features(desc, scaling_data);
  else
    desc = normalize_features(desc, scaling_data);
  end

  % Fase 1: riconoscimento unknown
  rec_features = desc(:, rec_names);
  [rec_pred, ~] = predict(recognizer, rec_features);

  if rec_pred == -1
    label = 11;  % unknown
    return;
  end

  % Fase 2: classificazione della foglia
  class_features = desc(:, class_names);
  label = predict(classifier, class_features);
end
