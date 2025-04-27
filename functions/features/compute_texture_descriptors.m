function texture_table = compute_texture_descriptors(img, mask)
  % Verifica input
  if nargin < 2
      error('Devi fornire un''immagine e una maschera binaria.');
  end

  % Conversione in scala di grigi se necessario
  if size(img, 3) ~= 1
      img = rgb2gray(img);
  end

  % variabili di selezione
  useHistStat = true;
  useGLCM = true;
  useAvgEdge = true;

  features = [];
  feature_names = {};

  if useHistStat
    % Calcolo delle feature statistiche dell'istogramma
    % Selezione dei soli pixel della maschera
    roi_pixels = double(img(mask));
    [hist_features, hist_feature_names] = compute_hist_stats_descriptors(roi_pixels);
    features = [features, hist_features];
    feature_names = [feature_names, hist_feature_names];
  end

  if useGLCM
    % Calcolo delle feature GLCM
    [glcm_features, glcm_feature_names] = compute_glcm_features(img, mask);
    features = [features, glcm_features];
    feature_names = [feature_names, glcm_feature_names];
  end

  if useAvgEdge
    % Calcolo della media delle edge
    avg_edge = compute_avg_edge(img, mask);
    features = [features, avg_edge];
    feature_names = [feature_names, {'texture.avg_edge'}];
  end

  % Costruzione della table
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
