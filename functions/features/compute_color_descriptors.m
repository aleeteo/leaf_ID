function color_table = compute_color_descriptors(img, mask, varargin)
  % --- Input check ---
  if nargin < 2
      error('Devi fornire un''immagine e una maschera binaria.');
  end
  if size(img,3) ~= 3
      error('L''immagine deve essere RGB.');
  end

  % --- Parametri opzionali ---
  p = inputParser;
  addParameter(p, 'use_var', false, @(x) islogical(x));
  addParameter(p, 'compute_skewness', false, @(x) islogical(x));
  addParameter(p, 'compute_kurtosis', false, @(x) islogical(x));
  parse(p, varargin{:});
  use_var = p.Results.use_var;
  do_skew = p.Results.compute_skewness;
  do_kurt = p.Results.compute_kurtosis;

  % --- Preparazione immagini ---
  img = im2double(img);
  mask = mask > 0;
  labImg = rgb2lab(img);
  hsvImg = rgb2hsv(img);

  % --- Info per iterazione ---
  colorSpaces = {
      img,    {'Red', 'Green', 'Blue'};
      hsvImg, {'Hue', 'Saturation', 'Value'};
      labImg, {'L', 'A', 'B'};
  };
  num_stats = 1 + 1 + do_skew + do_kurt;  % mean + std/var + skew + kurt
  total_features = size(colorSpaces,1) * 3 * num_stats;

  % --- Preallocazione ---
  features = zeros(1, total_features);
  feature_names = cell(1, total_features);
  idx = 1;

  % --- Estrazione feature ---
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
      if use_var
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
      if do_skew
        features(idx) = skewness(values);
        feature_names{idx} = ['color.skew.' channelNames{c}];
        idx = idx + 1;
      end

      % Kurtosis
      if do_kurt
        features(idx) = kurtosis(values);
        feature_names{idx} = ['color.kurt.' channelNames{c}];
        idx = idx + 1;
      end
    end
  end

  % --- Output come table ---
  color_table = array2table(features, 'VariableNames', feature_names);
end
