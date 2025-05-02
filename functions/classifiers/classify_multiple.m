function pred = classify_multiple(img, mask, classifier, recognizer, scaling_data)
%CLASSIFY_MULTIPLE Classifica gli oggetti segmentati in un'immagine

  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  class_names = classifier.PredictorNames;
  rec_names   = recognizer.PredictorNames;

  for i = 1:num_labels
    item_mask = comps == i;
    label = classify_object(img, item_mask, classifier, recognizer, class_names, rec_names, scaling_data);
    pred(item_mask) = label;
  end
end
function label = classify_object(img, item_mask, classifier, recognizer, class_names, rec_names, scaling_data)
%CLASSIFY_OBJECT Classifica un singolo oggetto usando riconoscitore e classificatore

  desc = compute_descriptors(img, item_mask);
  desc = normalize_features(desc, scaling_data);

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
