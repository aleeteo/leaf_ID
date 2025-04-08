function pred = classify_multiple(img, mask)
  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  load('data/minmax.mat', 'minmax');
  load('data/trainedKnnMdl.mat', 'C'); % assume che C.ModelParameters.PredictorNames esista

  predictor_names = C.PredictorNames; % <- 25 nomi di feature

  for i = 1:num_labels
    item_mask = comps == i;
    label = classify_object(img, item_mask, minmax, C, predictor_names);
    pred(item_mask) = label;
  end
end

function label = classify_object(img, item_mask, minmax, model, predictor_names)
  [desc, f_names] = compute_descriptors(img, item_mask);
  T = build_feature_table(desc, f_names, predictor_names, minmax);
  label = predict(model, T);
end

function T = build_feature_table(desc, f_names, predictor_names, minmax)
  % Creazione della tabella
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(desc) - 1)];
  T_full = table('Size', [1, numel(f_names)], ...
                  'VariableTypes', feature_types, ...
                  'VariableNames', f_names);
  T_full(1, :) = desc;
  T_full = normalize_features(T_full, minmax);
  % Seleziona solo le feature specificate in predictor_names
  T = T_full(:, predictor_names);
end
