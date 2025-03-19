function [data, feature_names] = compute_all_descriptors()
  % Funzione per l'estrazione e il salvataggio dei descrittori di forma e texture
  % Output: 
  %   data - matrice numerica contenente le features per ogni immagine (labels comprese)
  %   feature_names - cell array contenente i nomi delle features

  %% operazioni preliminari
  % - caricamento delle immagini
  % - estrazione dei nomi delle features
  % - Preallocazione

  % Lettura dei file
  [images, masks, labels] = readlists_train();
  nimages = numel(images);
  
  % Lettura della prima immagine per determinare il numero di feature
  mask = imread(masks{1});
  img = imread(images{1});
  
  % calcolo i nomi per calcolare la lunghezza
  [~ , shape_names] = compute_shape_descriptors(img, mask);
  [~, texture_names] = compute_texture_descriptors(img, mask);
  [~, color_names] = compute_color_descriptors(img, mask);
  [~, edge_names] = compute_edge_descriptors(mask);
  
  nfeatures = length(shape_names) + length(texture_names) + ...
              length(color_names)+ length(edge_names);
  
  % Preallocazione della matrice data (nimages x (nfeatures + 1))
  data = zeros(nimages, nfeatures + 1);
  
  % Creazione dell'array con i nomi delle features
  feature_names = [{'Label'}, shape_names, texture_names, color_names, edge_names];
  
  %% ciclo sulle singole immagini per l'estrazione
  for i = 1:nimages
    % Lettura della maschera e immagine
    mask = imread(masks{i});
    img = imread(images{i});

    % trasformazione gemma per aumentare il contraste nelle ombre (foglia)
    % e ridurlo nelle alte luci (sfondo)
    labImg = rgb2lab(im2double(img));
    gamma = 0.8;
    labImg(:,:,1) = ((labImg(:,:,1)/100) .^ gamma)*100;
    img = uint8(lab2rgb(labImg)*255);
    
    % Conversione dell'etichetta in numero
    if ischar(labels{i}) || isstring(labels{i})
        data(i,1) = str2double(labels{i});
    else
        data(i,1) = labels{i};
    end
    
    % Calcolo dei descrittori di forma e texture
    shape_features = compute_shape_descriptors(img, mask);
    texture_features = compute_texture_descriptors(img, mask);
    color_features = compute_color_descriptors(img, mask);
    edge_features = compute_edge_descriptors(mask);
    
    % Assegnazione diretta alla matrice dei dati
    data(i, 2:end) = [shape_features , texture_features, color_features, edge_features];
  end

  data = normalize_features(data);
end

