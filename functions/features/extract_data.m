function [training_data, testing_data, minmax] = extract_data(class_struct, saveFlag)
  
  arguments
    class_struct struct
    saveFlag {mustBeNumericOrLogical} = false
  end

  nimages = 100;
  img = class_struct(1).image;
  mask = class_struct(1).masks{1};
  [~, feature_names] = compute_descriptors(img, mask, class_struct(1).label);

  % Creazione di una table vuota con colonne predefinite
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(feature_names) - 1)];
  training_data = table('Size', [nimages, numel(feature_names)], ...
               'VariableTypes', feature_types, ...
               'VariableNames', feature_names);
  testing_data = training_data;

  for i = 1:10
    nmasks = numel(class_struct(i).masks);
    img = class_struct(i).image;
    for j = 1:10
      mask = class_struct(i).masks{j};
      training_data((10*(i-1))+j, :) = compute_descriptors(img, mask, class_struct(i).label);
    end
    for j = 10:nmasks
      mask = class_struct(i).masks{j};
      testing_data((10*(i-1))+(j-10), :) = compute_descriptors(img, mask, class_struct(i).label);
    end
  end

  % Normalizzazione delle feature 
  [training_data, minmax] = normalize_features(training_data);
  [testing_data, ~] = normalize_features(testing_data, minmax);

  if saveFlag
    save('data/data.mat', "training_data", "testing_data", "minmax");
  end
end
