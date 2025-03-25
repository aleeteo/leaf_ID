function [features, feature_names] = compute_glcm_features(img)
  % funzione che calcola le features di GLCM
  % input: img = immagine in scala di grigi o non 
  % output: features = vettore con le features di GLCM
  %         feature_names = vettore con i nomi delle features di GLCM

  % Controllo input
  if nargin < 1
    error('Devi fornire un''immagine.');
  end

  % Calcolo della matrice di co-occorrenza (GLCM)
  offsets = [0 1; -1 1; -1 0; -1 -1]; % Offset per invarianza a rotazione

  % TODO: testare metriche di valutazione con opzioni deverse 
  % (symmetric = false, graylimits = [masked_img min(masked_img(:)) max(masked_img(:))])

  glcm = graycomatrix(img, 'Offset', offsets, 'Symmetric', true, 'NumLevels', 64);

  % estrazione delle feature statistiche relative alla GLCM
  stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
  
  % Creazione del vettore delle features
  features = [mean(stats.Contrast), mean(stats.Correlation), ...
              mean(stats.Energy), mean(stats.Homogeneity)];
  
  feature_names = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};

end
