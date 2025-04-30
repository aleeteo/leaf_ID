function shape_table = compute_shape_descriptors(img, mask, options)
% COMPUTE_SHAPE_DESCRIPTORS Calcola i descrittori di forma per una regione fogliare.
%
%   shape_table = COMPUTE_SHAPE_DESCRIPTORS(img, mask, options) restituisce una tabella
%   con descrittori basati su morfologia, momenti di Hu e HuGray, a seconda delle opzioni.
%
%   options.shape_features: cell array con le feature da calcolare, tra:
%       'base'   - Compactness, Circularity, Eccentricity
%       'hu'     - Momenti invarianti di Hu su maschera
%       'hugray' - Momenti invarianti di Hu sull'immagine RGB
%
%   Default: options.shape_features = {'base', 'hu', 'hugray'}

  arguments
    img (:,:,3) uint8
    mask (:,:) logical
    options.shape_features cell = {'base', 'hu', 'hugray'}
  end

  featuresToUse = options.shape_features;

  % Validazione dei nomi delle feature
  valid_features = {'base', 'hu', 'hugray'};
  if ~all(ismember(featuresToUse, valid_features))
      error('Valori non validi in options.shape_features. Ammessi: base, hu, hugray.');
  end

  % Etichettatura della regione connessa
  stats = regionprops(mask, 'Area', 'Perimeter', 'Eccentricity');

  % Verifica presenza di oggetti nella maschera
  if isempty(stats)
      error('La maschera non contiene oggetti validi.');
  end

  features = [];
  feature_names = {};

  if ismember('base', featuresToUse)
      % Estrazione proprietà base
      area        = stats.Area;
      perimeter   = stats.Perimeter;
      eccentricity = stats.Eccentricity;

      % Feature derivate
      compactness = (perimeter^2) / area;
      circularity = (4 * pi * area) / (perimeter^2);

      features = [features, compactness, circularity, eccentricity];
      feature_names = [feature_names, {'shape.Compactness', 'shape.Circularity', 'shape.Eccentricity'}];
  end

  if ismember('hu', featuresToUse)
    % Calcolo dei momenti di Hu
    hu = compute_hu_moments(mask);
    hu_names = {'shape.Hu.1', 'shape.Hu.2', 'shape.Hu.3', 'shape.Hu.4', ...
                'shape.Hu.5', 'shape.Hu.6', 'shape.Hu.7'};

    features = [features, hu];
    feature_names = [feature_names, hu_names];
  end

  if ismember('hugray', featuresToUse)
    % Calcolo dei momenti di Hu sull'immagine originale
    hu_gray = compute_hu_moments(mask, img);
    hu_gray_names = {'shape.HuGray.1', 'shape.HuGray.2', 'shape.HuGray.3', ...
                      'shape.HuGray.4', 'shape.HuGray.5', 'shape.HuGray.6', ...
                      'shape.HuGray.7'};

    features = [features, hu_gray];
    feature_names = [feature_names, hu_gray_names];
  end

  % Costruzione della table
  shape_table = array2table(features, 'VariableNames', feature_names);
end


