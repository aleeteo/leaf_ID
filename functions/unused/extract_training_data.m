function [data, minmax] = extract_training_data(saveFlag)
  % Funzione per l'estrazione e il salvataggio dei descrittori di forma e texture
  % Input: save (opzionale) - se true, salva i dati in un file .mat
  % Output: 
  %   data - table contenente le features per ogni immagine (labels comprese)
  %          e nomi delle features
  %   minmax - valori minimi e massimi per la normalizzazione delle feature
  
  arguments
    saveFlag {mustBeNumericOrLogical} = false
  end

  % Lettura dei file
  [images, masks, labels] = readlists_train();
  nimages = numel(images);

  % Ottenere i nomi delle feature dalla prima immagine
  img = imread(images{1});
  mask = imread(masks{1});
  [~, feature_names] = compute_descriptors(img, mask, labels(1));

  % Creazione di una table vuota con colonne predefinite
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(feature_names) - 1)];
  data = table('Size', [nimages, numel(feature_names)], ...
               'VariableTypes', feature_types, ...
               'VariableNames', feature_names);

  % Estrazione delle feature per ogni immagine
  for i = 1:nimages
    img = imread(images{i});
    mask = imread(masks{i});
    data(i, :) = compute_descriptors(img, mask, labels(i));
  end

  % Normalizzazione delle feature 
  if nargout == 2
    [data, minmax] = normalize_features(data);
  else
    data = normalize_features(data);
  end

  if saveFlag
    save('data/training_data.mat', 'data');
    save('data/minmax.mat', 'minmax');
  end
end
