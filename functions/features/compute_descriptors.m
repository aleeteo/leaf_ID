function descriptors = compute_descriptors(img, mask, label)
  % COMPUTE_DESCRIPTORS Calcola i descrittori per una regione fogliare.
  %
  %   descriptor_row = compute_descriptors(img, mask, label)
  %
  %   INPUT:
  %       img   - Immagine RGB della foglia (matrix HxWx3)
  %       mask  - Maschera binaria (HxW) della foglia
  %       label - Etichetta della foglia (stringa o char array)
  %
  %   OUTPUT:
  %       descriptor_row - Tabella contenente:
  %           - La label come variabile categorica
  %           - I descrittori shape, texture, color ed edge
  %
  %   NOTE:
  %       - Esegue una pre-elaborazione sul canale L* per uniformare l’illuminazione.
  %       - Usa le funzioni modulari per l’estrazione dei descrittori.
  %       - Tutte le feature sono contenute in una singola riga della tabella.
  %
  %   REQUIRES:
  %       compute_shape_descriptors
  %       compute_texture_descriptors
  %       compute_color_descriptors
  %       compute_edge_descriptors

  arguments
    img (:, :, :)
    mask (:, :)
    label char = 'undefined'
  end

  % Preprocessing del canale L*
  labImg = rgb2lab(im2double(img));
  gamma = 0.7;
  labImg(:,:,1) = ((labImg(:,:,1) / 100) .^ gamma) * 100;
  img_preprocessed = uint8(lab2rgb(labImg) * 255);

  % Estrazione tabelle descrittori
  shape_table   = compute_shape_descriptors(img_preprocessed, mask);
  texture_table = compute_texture_descriptors(img_preprocessed, mask);
  color_table   = compute_color_descriptors(img_preprocessed, mask);
  edge_table    = compute_edge_descriptors(mask);

  % Crea tabella con label
  label_col = table(categorical({label}), 'VariableNames', {'Label'});

  % Unione finale
  descriptors = [label_col, shape_table, texture_table, color_table, edge_table];
end


