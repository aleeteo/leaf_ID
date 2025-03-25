function [normData, minmax] = normalize_features(data, minmax)
  % input: 
  %   - data: table contenente le features da normalizzare e labels (prima colonna)
  %   - mimax: (opzionale) matrice contenente i valori minimi e massimi di ogni feature
  % output:
  %   - data_normalized: matrice numerica (prima colonna = labels, altre colonne = features normalizzate)
  %   - minmax: (opzionale) matrice contenenete i valori minimi e massimi di ogni feature
  
  %controlli sugli argomenti
  arguments
    data table
    % minmax (2,:) table {mustBeNumeric} = []
    minmax (2, :) table = []
  end
  if size(minmax, 2) ~= size(data, 2) - 1 && size(minmax, 2) ~= 0
    error('Il numero di colonne di minmax deve essere uguale al numero di colonne di data - 1');
  end
  
  % Estrarre solo le features (escludendo la colonna delle labels)
  features = data(:, 2:end);
  
  % Normalizzare le features (normalizzazione min-max)
  if size(minmax, 2) ~= 0 
    minmax = [min(features); max(features)];
  end
  features_normalized = (features - minmax(1, :)) ./ (minmax(2, :) - minmax(1, :));

  normData = [data(:,1), features_normalized];
end
