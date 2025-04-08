function [normData, minmax] = normalize_features(data, minmax, hasLabels)
  % input: 
  %   - data: table contenente le features da normalizzare e labels (prima colonna)
  %   - mimax: (opzionale) matrice contenente i valori minimi e massimi di ogni feature
  %   - hasLabels: (opzionale) booleano che indica se la prima colonna di data contiene le labels
  % output:
  %   - data_normalized: matrice numerica (prima colonna = labels, altre colonne = features normalizzate)
  %   - minmax: (opzionale) matrice contenenete i valori minimi e massimi di ogni feature
  
  %controlli sugli argomenti
  arguments
    data table
    minmax table = table()
    hasLabels logical = true
  end
  
  % Estrazione delle features
  if hasLabels
    features = data(:, 2:end);
  else
    features = data;
  end

  % Se minmax è vuota, calcola i valori
  if isempty(minmax)
    minmax = [min(features); max(features)];
  else
    if height(minmax) ~= 2 || width(minmax) ~= width(features)
      error('minmax deve avere 2 righe e lo stesso numero di colonne delle feature.');
    end
  end

  features_normalized = (features - minmax(1, :)) ./ (minmax(2, :) - minmax(1, :));

  % eventuale clipping dei valori normalizzati
  features_normalized = max(min(features_normalized, 1), 0);  % clipping in [0,1]

  if hasLabels
      normData = [data(:,1), features_normalized];
  else
      normData = features_normalized;
  end
end
