function cm_table = compute_correlation_matrix(data, show)
  % Calcola e visualizza la matrice di correlazione tra le feature in una tabella
  % INPUT:
  %   - data: table, prima colonna = labels (non usata), da 2 in poi = feature numeriche
  %   - show: (opzionale) true per stampare la tabella di correlazione
  % OUTPUT:
  %   - cm: matrice di correlazione

  arguments
    data table
    show (1,1) logical = false
  end

  % Isolare solo le colonne numeriche tra le features
  feature_vars = data(:, 2:end);
  is_numeric_col = varfun(@isnumeric, feature_vars, 'OutputFormat', 'uniform');
  feature_vars = feature_vars(:, is_numeric_col);

  % Estrarre i dati come array
  features = feature_vars{:,:};

  % Calcolo matrice di correlazione
  cm = corrcoef(features);
  var_names = feature_vars.Properties.VariableNames;
  cm_table = array2table(cm, 'VariableNames', var_names, 'RowNames', var_names);

  % Visualizzazione opzionale
  if show
    fprintf('Matrice di correlazione:\n');
    disp(cm_table);
  end
end
