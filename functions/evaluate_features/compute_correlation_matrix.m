function cm = compute_correlation_matrix(data, feature_names, show)
  % funzione per la visualizzazione della matrice di correlazione
  % input: 
  %   - data: matrice numerica (prima colonna = labels, altre colonne = features)
  %   - feature_names: (opzionale) cell array contenente i nomi delle features
  %   - show: (opzionale) booleano che indica se visualizzare la matrice di correlazione
  % output:
  %   - cm: matrice di correlazione
  
  arguments
    data (:,:) double
    feature_names cell = {}
    show (1,1) logical = false
  end

  % Estrarre solo le features (escludendo la colonna delle labels)
  features = data(:, 2:end);
  
  % Calcolare la matrice di correlazione
  cm = corrcoef(features);

  if (show == true)
    if length(feature_names) ~= length(cm, 'rows')
      disp(cm)
    else
      % Visualizzare la matrice di correlazione con i nomi delle features
      feature_names = feature_names(2:end)';
      fprintf('Matrice di correlazione:\n');
      disp(array2table(cm, 'VariableNames', feature_names, 'RowNames', feature_names));
    end
  end
end
