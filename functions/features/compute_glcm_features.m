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
