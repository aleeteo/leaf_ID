function pred = classify_multiple_cl(img, mask, C, scaling_data)

  arguments
    img (:, :, 3) uint8
    mask (:, :) logical
    C
    scaling_data (:,:) table = []
  end

  [comps, num_labels] = bwlabel(mask);
  pred = zeros(size(mask));

  if size(scaling_data, 1) == 0
    load('data/scaling_data_augmented.mat', 'scaling_data_augmented');
  else
    scaling_data_augmented = scaling_data;
  end

  for i = 10:num_labels
    item_mask = (comps == i);
    label = classify_object(img, item_mask, scaling_data_augmented, C);
    pred(item_mask) = label;
  end
end

function label = classify_object(img, item_mask, scaling_data_augmened, model)
  [desc, f_names] = compute_descriptors(img, item_mask);
  T = build_feature_table(desc, f_names, scaling_data_augmened);
  % label = predict(model, T);
  label = model.predictFcn(T);
end

function T = build_feature_table(desc, f_names, scaling_data_augmented)
  % Creazione della tabella
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(desc) - 1)];
  T = table('Size', [1, numel(f_names)], ...
                  'VariableTypes', feature_types, ...
                  'VariableNames', f_names);
  T(1, :) = desc;
  T = normalize_features(T, scaling_data_augmented);
end
