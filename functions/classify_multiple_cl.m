function pred = classify_multiple_cl(img, mask, C)
  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  load('data/minmax.mat', 'minmax');

  for i = 1:num_labels
    item_mask = (comps == i);
    label = classify_object(img, item_mask, minmax, C);
    pred(item_mask) = label;
  end
end

function label = classify_object(img, item_mask, minmax, model)
  [desc, f_names] = compute_descriptors(img, item_mask);
  T = build_feature_table(desc, f_names, minmax);
  % label = predict(model, T);
  label = model.predictFcn(T);
end

function T = build_feature_table(desc, f_names, minmax)
  % Creazione della tabella
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(desc) - 1)];
  T = table('Size', [1, numel(f_names)], ...
                  'VariableTypes', feature_types, ...
                  'VariableNames', f_names);
  T(1, :) = desc;
  T = normalize_features(T, minmax);
end
