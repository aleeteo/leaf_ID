clear
close all

load('data/data.mat')
img = imread("dataset/05_unknown/images/unknown_03.jpg");
mask = imread("dataset/05_unknown/masks/unknown_03_mask.png");
labels = load("dataset/05_unknown/labels/unknown_03_label.mat").labeledImage;

is_leaf = train_leaf_recognizer(training_data);

[comps, num_labels] = bwlabel(mask);
pred = zeros(size(mask));

for i = 1:num_labels
  item_mask = comps == i;
  label = classify_object(img, item_mask, minmax, is_leaf);
  pred(item_mask) = label;
end

figure;
imagesc(pred);
axis image;
axis off;

function label = classify_object(img, item_mask, minmax, is_leaf)
  [desc, f_names] = compute_descriptors(img, item_mask);
  T = build_feature_table(desc, f_names, minmax);
  % print(T(:, {'Circularity', 'meanA', 'HuMoment1'}))
  isLeaf = is_leaf(T);
  if isLeaf
    label = 1;
  else 
    label = 2;
  end
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


