function descriptors = compute_descriptors(img, mask, label, options)
% COMPUTE_DESCRIPTORS Estrae descrittori morfologici, texture, colore e bordo da una foglia.
%
%   descriptors = COMPUTE_DESCRIPTORS(img, mask, label, options)
%
%   INPUT:
%     img     - Immagine RGB (HxWx3) contenente la foglia
%     mask    - Maschera binaria (HxW) che segmenta la foglia
%     label   - Etichetta della foglia come stringa/char
%     options - Struttura con:
%         .preprocess         : true/false, applica correzione gamma al canale L* (default: true)
%         .feature_modules    : cell array con i moduli attivi tra 'shape', 'texture', 'color', 'edge'
%         .shape_features     : feature di forma da estrarre, es. {'base','hu','hugray'}
%         .texture_features   : feature di texture, es. {'hist','glcm','avgedge'}
%         .color_spaces       : spazi colore, es. {'RGB','Lab'}
%         .use_var            : se true usa varianza anziché std
%         .compute_skewness   : se true calcola la skewness
%         .compute_kurtosis   : se true calcola la kurtosis
%         .edge_features      : feature edge da estrarre, es. {'signature'}
%
%   OUTPUT:
%     descriptors - Tabella con una riga, contenente:
%         - La label come categoria
%         - I descrittori estratti in base ai moduli selezionati
%
%   NOTA:
%     Tutte le funzioni richiamate usano opzioni modulari in ingresso per ciascun tipo di feature.
%     Questa funzione funge da orchestratore centralizzato della pipeline di estrazione.

  arguments
    img (:, :, 3) uint8
    mask (:, :, 1) logical
    label char = 'undefined'
    options.preprocess (1, 1) logical = true
    options.feature_modules cell = {'shape','texture','color','edge'}
    options.shape_features cell = {'base','hu','hugray'}
    options.texture_features cell = {'hist','glcm','avgedge'}
    options.color_spaces cell = {'RGB','HSV','Lab'}
    options.use_var logical = false
    options.compute_skewness logical = false
    options.compute_kurtosis logical = false
    options.edge_features cell = {'signature'}
  end

  % Validazione moduli richiesti
  valid_modules = {'shape', 'texture', 'color', 'edge'};
  if ~all(ismember(options.feature_modules, valid_modules))
    error('Valori non validi in options.feature_modules. Ammessi: shape, texture, color, edge.');
  end

  modules = options.feature_modules;

  if options.preprocess
    labImg = rgb2lab(im2double(img));
    gamma = 0.7;
    labImg(:,:,1) = ((labImg(:,:,1) / 100) .^ gamma) * 100;
    img = uint8(lab2rgb(labImg) * 255);
  end

  label_col = table(categorical({label}), 'VariableNames', {'Label'});
  descriptors = label_col;

  if ismember('shape', modules)
    shape_table = compute_shape_descriptors(img, mask, ...
                    "shape_features", options.shape_features);
    descriptors = [descriptors, shape_table];
  end

  if ismember('texture', modules)
    texture_table = compute_texture_descriptors(img, mask, ...
                      "texture_features", options.texture_features);
    descriptors = [descriptors, texture_table];
  end

  if ismember('color', modules)
    color_table = compute_color_descriptors(img, mask, ...
                    "color_spaces", options.color_spaces, ...
                    "use_var", options.use_var, ...
                    "compute_skewness", options.compute_skewness, ...
                    "compute_kurtosis", options.compute_kurtosis);
    descriptors = [descriptors, color_table];
  end

  if ismember('edge', modules)
    edge_table = compute_edge_descriptors(mask, ...
                    "edge_features", options.edge_features);
    descriptors = [descriptors, edge_table];
  end
end
