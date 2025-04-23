function pred = classify_multiple(img, mask, C, minmax)
  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  predictor_names = C.PredictorNames; % <- 25 nomi di feature

  for i = 1:num_labels
    item_mask = comps == i;
    label = classify_object(img, item_mask, minmax, C, predictor_names);
    pred(item_mask) = label;
  end
end

function label = classify_object(img, item_mask, minmax, model, predictor_names)
  desc = compute_descriptors(img, item_mask);
  % T = build_feature_table(desc, f_names, predictor_names, minmax);
  desc = normalize_features(desc, minmax);
  desc = desc(:, predictor_names);

  label = predict(model, desc);
end
