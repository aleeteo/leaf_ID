function [data, minmax] = extract_training_data_classes(traning_struct, saveFlag)
  
  arguments
    traning_struct struct
    saveFlag {mustBeNumericOrLogical} = false
  end

  nimages = 100;
  img = traning_struct(1).image;
  mask = traning_struct(1).masks{1};
  [~, feature_names] = compute_descriptors(img, mask, traning_struct(1).label);

  % Creazione di una table vuota con colonne predefinite
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(feature_names) - 1)];
  data = table('Size', [nimages, numel(feature_names)], ...
               'VariableTypes', feature_types, ...
               'VariableNames', feature_names);

  for i = 1:10
    for j = 1:10
      img = traning_struct(i).image;
      mask = traning_struct(i).masks{j};
      data((10*(i-1))+j, :) = compute_descriptors(img, mask, traning_struct(i).label);
    end
  end

  % Normalizzazione delle feature 
  if (nargout == 2 || saveflag)
    [data, minmax] = normalize_features(data);
  else
    data = normalize_features(data);
  end

  if saveFlag
    save('data/training_data.mat', 'data');
    save('data/minmax.mat', 'minmax');
  end
end
