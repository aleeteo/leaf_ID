function pred = classify_multiple_cl(img, mask, C, minmax)

  arguments
    img (:, :, 3) uint8
    mask (:, :) logical
    C
    minmax (:,:) table = []
  end

  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  if size(minmax, 1) == 0
    load('data/minmax_augmented.mat', 'minmax_augmented');
  else
    minmax_augmented = minmax;
  end

  for i = 10:num_labels
    item_mask = (comps == i);
    label = classify_object(img, item_mask, minmax_augmented, C);
    pred(item_mask) = label;
  end
end

function label = classify_object(img, item_mask, minmax_augmened, model)
  [desc, f_names] = compute_descriptors(img, item_mask);
  T = build_feature_table(desc, f_names, minmax_augmened);
  % label = predict(model, T);
  label = model.predictFcn(T);
end

function T = build_feature_table(desc, f_names, minmax_augmented)
  % Creazione della tabella
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(desc) - 1)];
  T = table('Size', [1, numel(f_names)], ...
                  'VariableTypes', feature_types, ...
                  'VariableNames', f_names);
  T(1, :) = desc;
  T = normalize_features(T, minmax_augmented);
end
