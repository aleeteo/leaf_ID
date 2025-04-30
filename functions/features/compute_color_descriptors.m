function color_table = compute_color_descriptors(img, mask, options)
% COMPUTE_COLOR_DESCRIPTORS Estrae descrittori statistici dai canali colore di un'immagine.
%
%   color_table = COMPUTE_COLOR_DESCRIPTORS(img, mask, options) estrae media, deviazione standard
%   (o varianza), skewness e kurtosis dai canali specificati in options.color_spaces.
%
%   Parametri in options:
%     - color_spaces: cell array con spazi colore da usare ('RGB', 'HSV', 'Lab', 'YCbCr', 'XYZ')
%     - use_var: se true usa la varianza anziché la deviazione standard (default: false)
%     - compute_skewness: se true calcola la skewness (default: false)
%     - compute_kurtosis: se true calcola la kurtosis (default: false)
%
%   Output:
%     - color_table: tabella con i descrittori estratti

  arguments
    img (:,:,3) uint8
    mask (:,:) logical
    options.color_spaces cell = {'RGB', 'HSV', 'Lab'}
    options.use_var logical = false
    options.compute_skewness logical = false
    options.compute_kurtosis logical = false
  end

  % Validazione spazi colore
  allowed_spaces = {'RGB', 'HSV', 'Lab', 'YCbCr', 'XYZ'};
  if ~all(ismember(options.color_spaces, allowed_spaces))
    error('Spazi colore non validi. Ammessi: RGB, HSV, Lab, YCbCr, XYZ');
  end

  % Preparazione immagini
  img = im2double(img);
  mask = mask > 0;

  % Mappa nomi canali
  namesMap = struct( ...
    'RGB',   {{'Red','Green','Blue'}}, ...
    'HSV',   {{'Hue','Saturation','Value'}}, ...
    'Lab',   {{'L','A','B'}}, ...
    'YCbCr', {{'Y','Cb','Cr'}}, ...
    'XYZ',   {{'X','Y','Z'}} ...
  );

  % Costruzione dinamica degli spazi colore
  colorSpaces = {};
  if any(strcmp(options.color_spaces, 'RGB'))
      colorSpaces(end+1,:) = {img, namesMap.RGB};
  end
  if any(strcmp(options.color_spaces, 'HSV'))
      hsvImg = rgb2hsv(img);
      colorSpaces(end+1,:) = {hsvImg, namesMap.HSV};
  end
  if any(strcmp(options.color_spaces, 'Lab'))
      labImg = rgb2lab(img);
      colorSpaces(end+1,:) = {labImg, namesMap.Lab};
  end
  if any(strcmp(options.color_spaces, 'YCbCr'))
      ycbcrImg = rgb2ycbcr(img);
      colorSpaces(end+1,:) = {ycbcrImg, namesMap.YCbCr};
  end
  if any(strcmp(options.color_spaces, 'XYZ'))
      cform = makecform('srgb2xyz');
      xyzImg = applycform(img, cform);
      colorSpaces(end+1,:) = {xyzImg, namesMap.XYZ};
  end

  % Numero statistiche per canale
  num_stats = 1 + 1 + options.compute_skewness + options.compute_kurtosis;
  num_channels = 3 * size(colorSpaces, 1);
  total_features = num_channels * num_stats;

  % Preallocazione
  features = zeros(1, total_features);
  feature_names = cell(1, total_features);
  idx = 1;

  % Estrazione feature
  for i = 1:size(colorSpaces, 1)
    colorImg = colorSpaces{i,1};
    channelNames = colorSpaces{i,2};

    for c = 1:3
      channel = colorImg(:,:,c);
      values = channel(mask);

      % Media
      mu = mean(values);
      features(idx) = mu;
      feature_names{idx} = ['color.mean.' channelNames{c}];
      idx = idx + 1;

      % Varianza o Dev. Standard
      if options.use_var
        val = var(values);
        name = ['color.var.' channelNames{c}];
      else
        val = std(values);
        name = ['color.std.' channelNames{c}];
      end
      features(idx) = val;
      feature_names{idx} = name;
      idx = idx + 1;

      % Skewness
      if options.compute_skewness
        features(idx) = skewness(values);
        feature_names{idx} = ['color.skew.' channelNames{c}];
        idx = idx + 1;
      end

      % Kurtosis
      if options.compute_kurtosis
        features(idx) = kurtosis(values);
        feature_names{idx} = ['color.kurt.' channelNames{c}];
        idx = idx + 1;
      end
    end
  end

  % Output come table
  color_table = array2table(features, 'VariableNames', feature_names);
end
