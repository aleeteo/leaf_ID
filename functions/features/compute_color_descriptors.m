function [features, feature_names] = compute_color_descriptors(img, mask, varargin)
% compute_color_descriptors  Estrae descrittori statistici di colore da una regione mascherata.
%
%   [features, feature_names] = compute_color_descriptors(img, mask)
%       Calcola le statistiche dei pixel nei tre spazi colore (RGB, HSV, LAB)
%       per l'immagine RGB `img` usando la maschera binaria `mask`.
%       Restituisce un vettore `features` e i nomi corrispondenti.
%
%   [...] = compute_color_descriptors(..., 'Name', Value, ...)
%       Permette di specificare opzioni aggiuntive tramite coppie nome/valore.
%
%   Opzioni:
%     'use_var'          - Se true, calcola la varianza anziché la deviazione standard (default: false)
%     'compute_skewness' - Se true, calcola la skewness per ogni canale (default: false)
%     'compute_kurtosis' - Se true, calcola la kurtosis per ogni canale (default: false)
%
%   Output:
%     features        - Vettore riga contenente le statistiche concatenate
%     feature_names   - Cell array con i nomi delle feature, utile per riferimento
%
%   Feature calcolate:
%     - Media di ciascun canale nei tre spazi colore (RGB, HSV, LAB)
%     - Deviazione standard o varianza per ciascun canale
%     - (Opzionale) Skewness e kurtosis per ciascun canale
%
%   Esempio:
%     img = imread('leaf.jpg');
%     mask = imbinarize(rgb2gray(img));
%     [f, names] = compute_color_descriptors(img, mask, ...
%                  'use_var', false, 'compute_skewness', true);
%
%   Note:
%     - L'immagine viene convertita automaticamente in double
%     - La maschera viene binarizzata internamente
%     - Il vettore delle feature ha dimensione variabile in base alle opzioni

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
          feature_names{idx} = ['mean' channelNames{c}];
          idx = idx + 1;

          % Varianza o Dev. Standard
          if use_var
              val = var(values);
              name = ['var' channelNames{c}];
          else
              val = std(values);
              name = ['std' channelNames{c}];
          end
          features(idx) = val;
          feature_names{idx} = name;
          idx = idx + 1;

          % Skewness
          if do_skew
              features(idx) = skewness(values);
              feature_names{idx} = ['skew' channelNames{c}];
              idx = idx + 1;
          end

          % Kurtosis
          if do_kurt
              features(idx) = kurtosis(values);
              feature_names{idx} = ['kurt' channelNames{c}];
              idx = idx + 1;
          end
      end
  end
end
