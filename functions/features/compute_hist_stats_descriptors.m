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
