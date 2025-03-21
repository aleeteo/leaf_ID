function data = extract_test_data(saveFlag)
  % Funzione per l'estrazione e il salvataggio dei descrittori di forma e texture
  % Input: save (opzionale) - se true, salva i dati in un file .mat
  % Output: 
  %   data - table contenente le features per ogni immagine (labels comprese)
  %          e nomi delle features
  
  arguments
    saveFlag {mustBeNumericOrLogical} = false
  end

  % Lettura dei file
  [images, masks, labels] = readlists_test();
  nimages = numel(images);

  % Ottenere i nomi delle feature dalla prima immagine
    img = imread(['dataset/02_test/images/' images{1}]);
    mask = imread(['dataset/02_test/masks/' masks{1}]);
  [~, feature_names] = compute_descriptors(img, mask, labels(1));

  % Creazione di una table vuota con colonne predefinite
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(feature_names) - 1)];
  data = table('Size', [nimages, numel(feature_names)], ...
               'VariableTypes', feature_types, ...
               'VariableNames', feature_names);

  % Estrazione delle feature per ogni immagine
  for i = 1:nimages
    img = imread(['dataset/02_test/images/' images{i}]);
    mask = imread(['dataset/02_test/masks/' masks{i}]);
    data(i, :) = compute_descriptors(img, mask, labels(i));
  end

  % Normalizzazione delle feature 
  load('data/minmax.mat', 'minmax');
  data = normalize_features(data, minmax);

  if saveFlag
    save('data/testing_data.mat', 'data');
  end
end
