function [features, feature_names] = compute_texture_descriptors(img, mask)
  % Controllo input
  if nargin < 2
    error('Devi fornire un''immagine e una maschera binaria.');
  end
  
  % Controllo che l'immagine sia in scala di grigi
  if size(img, 3) ~= 1
    img = rgb2gray(img);
  end

  masked_img = img .* uint8(mask);

  [glcm_features, glcm_feature_names] = compute_glcm_features(masked_img);
  [stat_features, stats_feature_names] = compute_hist_stats_descriptors(masked_img);
  avg_edge = compute_avg_edge(img, mask);

  features = [glcm_features, avg_edge, stat_features];

  % controllo sul numero di output
  if nargout > 1 
    feature_names = [glcm_feature_names, {'avg_edge'}, stats_feature_names];
  end
end
