function [data_normalized, minmax] = normalize_features(data)
  % input: 
  %   - data: table contenente le features da normalizzare e labels (prima colonna)
  % output:
  %   - data_normalized: matrice numerica (prima colonna = labels, altre colonne = features normalizzate)
  %   - minmax: (opzionale) matrice contenenete i valori minimi e massimi di ogni feature
  
  % Estrarre solo le features (escludendo la colonna delle labels)
  features = data(:, 2:end);
  
  % Normalizzare le features (normalizzazione min-max)
  features_normalized = features;

  for i = 1:size(features, 2)
    features_normalized(:, i) = (features(:, i) - min(features(:, i))) ./ (max(features(:, i)) - min(features(:, i)));
  end

  data_normalized = [data(:,1), features_normalized];
  % Restituire min e max solo se richiesto
  if nargout > 1
    minmax = [min(features); max(features)];
  end
end
