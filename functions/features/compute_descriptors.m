function [descriptor_row, feature_names] = compute_descriptors(img, mask, label)
  % Funzione per calcolare i descrittori di un'immagine e restituire una riga di dati
  % Input:
  %   - img: immagine in formato matrice
  %   - mask: maschera binaria associata all'immagine
  %   - label: etichetta dell'immagine
  % Output:
  %   - descriptor_row: riga di una table con label e descrittori
  %   - feature_names: opzionale, cell array con i nomi dei descrittori
  %
  arguments
    img (:, :, :)
    mask (:, :)
    label char = 'undefined'
  end

  % Pre-elaborazione immagine (correzione gamma su canale L*)
  labImg = rgb2lab(im2double(img));
  gamma = 0.7;
  labImg(:,:,1) = ((labImg(:,:,1) / 100) .^ gamma) * 100;
  img_preprocessed = uint8(lab2rgb(labImg) * 255);
  
  % Conversione dell'etichetta in formato categoriale
  if ~iscell(label)
      label = {label}; % lo converte in cella se non lo è già
  end
  label = categorical(label);

  % Estrazione delle feature
  [shape_features, shape_names] = compute_shape_descriptors(img_preprocessed, mask);
  [texture_features, texture_names] = compute_texture_descriptors(img_preprocessed, mask);
  [color_features, color_names] = compute_color_descriptors(img_preprocessed, mask);
  [edge_features, edge_names] = compute_edge_descriptors(mask);
  
  % Creazione della table separando label e feature numeriche
  label_table = table(label, 'VariableNames', {'Label'});
  feature_table = array2table([shape_features, texture_features, color_features, edge_features]);

  % Unire le due table in una riga
  descriptor_row = [label_table, feature_table];

  % Inizializzazione opzionale dei nomi delle feature
  feature_names = {};
  if nargout > 1
    feature_names = [{'Label'}, shape_names, texture_names, color_names, edge_names];
  end
end


