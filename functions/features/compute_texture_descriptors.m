function texture_table = compute_texture_descriptors(img, mask, options)
% COMPUTE_TEXTURE_DESCRIPTORS Calcola i descrittori di texture da un'immagine.
%
%   texture_table = COMPUTE_TEXTURE_DESCRIPTORS(img, mask, options) restituisce una tabella
%   con le statistiche dell'istogramma, GLCM, LBP e edge gradienti a seconda delle opzioni.
%
%   Parametri in options:
%     - texture_features: cell array con i blocchi da attivare tra:
%         'hist'   : statistiche dell'istogramma (mean, var, ecc.)
%         'glcm'   : GLCM features (contrast, correlation, ecc.)
%         'rilbp'  : Local Binary Pattern rotation-invariant (TODO)
%         'avgedge': media del gradiente sull'oggetto
%
%     Default: {'hist', 'glcm', 'avgedge'}

  arguments
    img (:,:,3) uint8
    mask (:,:) logical
    options.texture_features cell = {'hist', 'glcm', 'avgedge'}
  end

  valid_features = {'hist', 'glcm', 'rilbp', 'avgedge'};
  if ~all(ismember(options.texture_features, valid_features))
    error('Valori non validi in options.texture_features. Ammessi: hist, glcm, rilbp, avgedge.');
  end

  % Conversione in scala di grigi
  if size(img, 3) ~= 1
    img = rgb2gray(img);
  end

  features = [];
  feature_names = {};

  if ismember('hist', options.texture_features)
    roi_pixels = double(img(mask));
    [hist_features, hist_feature_names] = compute_hist_stats_descriptors(roi_pixels);
    features = [features, hist_features];
    feature_names = [feature_names, hist_feature_names];
  end

  if ismember('glcm', options.texture_features)
    [glcm_features, glcm_feature_names] = compute_glcm_features(img, mask);
    features = [features, glcm_features];
    feature_names = [feature_names, glcm_feature_names];
  end

  if ismember('rilbp', options.texture_features)
    [rilbp_features, rilbp_feature_names] = compute_rilbp_features(img, mask);
    features = [features, rilbp_features];
    feature_names = [feature_names, rilbp_feature_names];
  end

  if ismember('avgedge', options.texture_features)
    avg_edge = compute_avg_edge(img, mask);
    features = [features, avg_edge];
    feature_names = [feature_names, {'texture.avg_edge'}];
  end

  % Costruzione della tabella
  texture_table = array2table(features, 'VariableNames', feature_names);
end


function [features ,feature_names] = compute_hist_stats_descriptors(roi_pixels)
  p = histcounts(roi_pixels, 0:256); % istogramma a 256 livelli
  p = p / sum(p); % normalizzazione

  levels = 0:255;
  levels = levels(p > 0); % solo livelli presenti
  p = p(p > 0);           

  mean_val = sum(levels .* p);
  variance = sum(((levels - mean_val).^2) .* p);
  skewness_val = sum(((levels - mean_val).^3) .* p) / (sqrt(variance)^3);
  kurtosis_val = sum(((levels - mean_val).^4) .* p) / (variance^2) - 3;
  energy = sum(p.^2);
  entropy_val = -sum(p .* log2(p));

  features = [mean_val, variance, skewness_val, kurtosis_val, energy, entropy_val];
  feature_names = {'texture.stat.mean', 'texture.stat.var', ...
                   'texture.stat.skewness', 'texture.stat.kurtosis', ...
                   'texture.stat.energy', 'texture.stat.entropy'};

end

function [features, feature_names] = compute_glcm_features(img, mask)
  % Ritaglia bounding box della regione della maschera
  props = regionprops(mask, 'BoundingBox');
  if isempty(props)
      error('La maschera non contiene regioni valide.');
  end
  bb = round(props(1).BoundingBox);
  roi = imcrop(img, bb);
  roi_mask = imcrop(mask, bb);
  roi(~roi_mask) = 0;

  % Calcolo della GLCM (su ROI)
  offsets = [0 1; -1 1; -1 0; -1 -1];
  glcm = graycomatrix(roi, ...
                      'Offset', offsets, ...
                      'Symmetric', true, ...
                      'NumLevels', 32);

  stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});

  features = [mean(stats.Contrast), mean(stats.Correlation), ...
              mean(stats.Energy), mean(stats.Homogeneity)];

  feature_names = {'texture.glcm.contrast', 'texture.glcm.correlation', ...
                'texture.glcm.energy', 'texture.glcm.homogeneity'};
end

function [avg_edge] = compute_avg_edge(img, mask)
  %funzione che calcola la media delle edge dell'immagine
  %input: img = immagine
  %       mask = maschera binaria dell'immagine
  %output: avg_edge = media delle edge dell'immagine

  area = regionprops(mask, 'Area').Area;
  img = double(img);
  [Gx, Gy] = gradient(img);
  Gx = Gx(mask);
  Gy = Gy(mask);

  avg_edge = sqrt(sum(Gx.^2 + Gy.^2) / area);
end
