function descriptors = compute_descriptors(img, mask, label)
  % COMPUTE_DESCRIPTORS Calcola i descrittori per una regione fogliare.
  %
  %   descriptors = compute_descriptors(img, mask, label)
  %
  %   INPUT:
  %       img   - Immagine RGB della foglia (matrix HxWx3)
  %       mask  - Maschera binaria (HxW) della foglia
  %       label - Etichetta della foglia (stringa o char array)
  %
  %   OUTPUT:
  %       descriptors - Tabella contenente:
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

  % variabili di selezione
  usePreprocessing = true;
  useShape = true;
  useTexture = true;
  useColor = true;
  useEdge = true;

  if usePreprocessing
    % Preprocessing del canale L*
    labImg = rgb2lab(im2double(img));
    gamma = 0.7;
    labImg(:,:,1) = ((labImg(:,:,1) / 100) .^ gamma) * 100;
    img = uint8(lab2rgb(labImg) * 255);
  end

  % Crea tabella con label
  label_col = table(categorical({label}), 'VariableNames', {'Label'});
  descriptors = label_col;

  if useShape
    shape_table   = compute_shape_descriptors(img, mask);
    descriptors = [descriptors, shape_table];
  end

  if useTexture
    texture_table = compute_texture_descriptors(img, mask);
    descriptors = [descriptors, texture_table];
  end

  if useColor
    color_table   = compute_color_descriptors(img, mask);
    descriptors = [descriptors, color_table];
  end

  if useEdge
    edge_table    = compute_edge_descriptors(mask);
    descriptors = [descriptors, edge_table];
  end
end


