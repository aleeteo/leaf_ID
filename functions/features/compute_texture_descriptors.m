function texture_table = compute_texture_descriptors(img, mask)
  % Verifica input
  if nargin < 2
      error('Devi fornire un''immagine e una maschera binaria.');
  end

  % Conversione in scala di grigi se necessario
  if size(img, 3) ~= 1
      img = rgb2gray(img);
  end

  % Applica maschera all'immagine
  masked_img = img .* uint8(mask);

  % Calcolo delle feature
  [glcm_features, glcm_feature_names] = compute_glcm_features(masked_img);
  [stat_features, stats_feature_names] = compute_hist_stats_descriptors(masked_img);
  avg_edge = compute_avg_edge(img, mask);

  % Aggregazione
  features = [glcm_features, avg_edge, stat_features];
  feature_names = [glcm_feature_names, {'avg_edge'}, stats_feature_names];

  % Costruzione della table
  texture_table = array2table(features, 'VariableNames', feature_names);
end

function [features, feature_names] = compute_glcm_features(img)
  % Funzione per il calcolo delle caratteristiche (features) basate sulla matrice di co-occorrenza dei livelli di grigio (GLCM).
  % Input: 
  %   - img: immagine in scala di grigi o immagine a colori (che verrà convertita in scala di grigi).
  % Output: 
  %   - features: vettore contenente le caratteristiche calcolate dalla GLCM.
  %   - feature_names: vettore contenente i nomi delle caratteristiche calcolate dalla GLCM.

  % Controllo input
  if nargin < 1
    error('Devi fornire un''immagine.');
  end

  % Calcolo della matrice di co-occorrenza (GLCM)
  offsets = [0 1; -1 1; -1 0; -1 -1]; % Direzioni multiple
  glcm = graycomatrix(img, ...
                      'Offset', offsets, ...
                      'Symmetric', true, ...
                      'NumLevels', 32); % Riduzione livelli di grigio

  % estrazione delle feature statistiche relative alla GLCM
  stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
  
  % Creazione del vettore delle features
  features = [mean(stats.Contrast), mean(stats.Correlation), ...
              mean(stats.Energy), mean(stats.Homogeneity)];
  
  feature_names = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};

end

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
