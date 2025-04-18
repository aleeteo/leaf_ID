function [data_augmented, minmax_augmented] = extract_training_data_augmented(saveFlag)
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
  molt_factor = numel(data_augmentation(img, mask));


  [~, feature_names] = compute_descriptors(img, mask, labels(1));

  % Creazione di una table vuota con colonne predefinite
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(feature_names) - 1)];
  data_augmented = table('Size', [nimages*molt_factor, numel(feature_names)], ...
               'VariableTypes', feature_types, ...
               'VariableNames', feature_names);

  % Estrazione delle feature per ogni immagine
  for i = 1:molt_factor:nimages
    img = imread(images{i});
    mask = imread(masks{i});
    [img_augmented, mask_augmented] = data_augmentation(img, mask);
    % data(i, :) = compute_descriptors(img, mask, labels(i));
    for j = 1:molt_factor
      % Estrazione delle feature per ogni immagine
      data_augmented(i + j - 1, :) = compute_descriptors(img_augmented{j}, mask_augmented{j}, labels(i));
    end
    
  end

  % Normalizzazione delle feature 
  if nargout == 2
    [data_augmented, minmax_augmented] = normalize_features(data_augmented);
  else
    data_augmented = normalize_features(data_augmented);
  end

  if saveFlag
    save('data/training_data_augmented.mat', 'data_augmented');
    save('data/minmax_augmented.mat', 'minmax_augmented');
  end
end
