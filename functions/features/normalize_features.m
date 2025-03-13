function data_normalized = normalize_features(data)
  % input: 
  %   - data: matrice numerica (prima colonna = labels, altre colonne = features)
  % output:
  %   - data_normalized: matrice numerica (prima colonna = labels, altre colonne = features normalizzate)
  
  % Estrarre solo le features (escludendo la colonna delle labels)
  features = data(:, 2:end);
  
  % Normalizzare le features
  features_normalized = features;
  for i = 1:size(features, 2)
    features_normalized(:, i) = (features(:, i) - min(features(:, i))) / (max(features(:, i)) - min(features(:, i)));
  end

  data_normalized = [data(:,1), features_normalized];
end
