function [features ,feature_names] = compute_hist_stats_descriptors(image)
  % Converte l'immagine in scala di grigi se necessario
  if size(image, 3) == 3
      image = rgb2gray(image);
  end
  
  % Calcola l'istogramma e normalizza
  [counts, levels] = imhist(image);
  p = counts / sum(counts); % Probabilità dei livelli di intensità
  
  % Calcolo delle feature statistiche
  mean_val = sum(levels .* p); % Media
  variance = sum(((levels - mean_val) .^ 2) .* p); % Varianza
  skewness = sum(((levels - mean_val) .^ 3) .* p) / (sqrt(variance)^3); % Asimmetria
  kurtosis = sum(((levels - mean_val) .^ 4) .* p) / (variance^2) - 3; % Curtosi
  energy = sum(p .^ 2); % Energia
  entropy_val = -sum(p(p>0) .* log2(p(p>0))); % Entropia
  
  features = [mean_val, variance, skewness, kurtosis, energy, entropy_val];
  feature_names = {'Media', 'Varianza', 'Asimmetria', 'Curtosi', 'Energia', 'Entropia'};
end
