function texture_table = compute_texture_descriptors(img, mask)
  % Verifica input
  if nargin < 2
      error('Devi fornire un''immagine e una maschera binaria.');
  end

  % Conversione in scala di grigi se necessario
  if size(img, 3) ~= 1
      img = rgb2gray(img);
  end

  % Selezione dei soli pixel della maschera
  roi_pixels = double(img(mask));

  % Calcolo delle feature
  [glcm_features, glcm_feature_names] = compute_glcm_features(img, mask);
  [stat_features, stats_feature_names] = compute_hist_stats_descriptors(roi_pixels);
  avg_edge = compute_avg_edge(img, mask);

  % Aggregazione
  features = [glcm_features, avg_edge, stat_features];
  feature_names = [glcm_feature_names, {'avg_edge'}, stats_feature_names];

  % Costruzione della table
  texture_table = array2table(features, 'VariableNames', feature_names);
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

  feature_names = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};
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
  feature_names = {'Media', 'Varianza', 'Asimmetria', 'Curtosi', 'Energia', 'Entropia'};
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
