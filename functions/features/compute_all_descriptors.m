function [data, minmax] = compute_all_descriptors()
  % Funzione per l'estrazione e il salvataggio dei descrittori di forma e texture
  % Output: 
  %   data - table contenente le features per ogni immagine (labels comprese)
  %          e nomi delle features

  % Lettura dei file
  [images, masks, labels] = readlists_train();
  nimages = numel(images);
  
  % Determinazione dei nomi delle feature
  % a del numero di esse
  mask = imread(masks{1});
  img = imread(images{1});
  [~, shape_names] = compute_shape_descriptors(img, mask);
  [~, texture_names] = compute_texture_descriptors(img, mask);
  [~, color_names] = compute_color_descriptors(img, mask);
  [~, edge_names] = compute_edge_descriptors(mask);
  
  nfeatures = length(shape_names) + length(texture_names) + ...
              length(color_names) + length(edge_names);
  
  % Creazione dell'array con i nomi delle features
  feature_names = [{'Label'}, shape_names, texture_names, color_names, edge_names];

  % Creazione di una table vuota con colonne predefinite
  data = table('Size', [nimages, nfeatures + 1], ...
               'VariableTypes', [{'categorical'}, repmat({'double'}, 1, nfeatures)], ...
               'VariableNames', feature_names);

  %% Estrazione delle feature per ogni immagine
  for i = 1:nimages
    % Lettura della maschera e immagine
    mask = imread(masks{i});
    img = imread(images{i});

    % Pre-elaborazione immagine
    labImg = rgb2lab(im2double(img));
    gamma = 0.7;
    labImg(:,:,1) = ((labImg(:,:,1) / 100) .^ gamma) * 100;
    img = uint8(lab2rgb(labImg) * 255);
    
    % Conversione dell'etichetta in formato categoriale
    data.Label(i) = categorical(labels(i));

    % Estrazione delle feature
    shape_features = compute_shape_descriptors(img, mask);
    texture_features = compute_texture_descriptors(img, mask);
    color_features = compute_color_descriptors(img, mask);
    edge_features = compute_edge_descriptors(mask);
    
    % Assegnazione dei dati alla table
    data(i, 2:end) = array2table([shape_features, texture_features, color_features, edge_features]);
  end

  % Normalizzazione delle feature 
  % controllo sul numero di output
  if nargout == 2
    [data, minmax] = normalize_features(data);
  else
    data = normalize_features(data);
  end

end
