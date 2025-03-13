function cm = compute_correlation_matrix(data, feature_names)
  % data: matrice numerica (prima colonna = labels, altre colonne = features)
  % feature_names: arraycell contenente i nomi delle features
  
  % Estrarre solo le features (escludendo la colonna delle labels)
  features = data(:, 2:end);
  feature_names = feature_names(2:end)';
  
  % Calcolare la matrice di correlazione
  cm = corrcoef(features);


  % disp("dimensioni cm")
  % disp(size(cm));
  % disp("dimensioni nomi features");
  % disp(size(feature_names));
  
  % Visualizzare la matrice di correlazione con i nomi delle features
  fprintf('Matrice di correlazione:\n');
  disp(array2table(cm, 'VariableNames', feature_names, 'RowNames', feature_names));
end
