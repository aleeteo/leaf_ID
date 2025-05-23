function [train_selected, test_selected, selected_features, idx] = select_top_features(train_data, test_data, n)
  % % Controlla che 'Label' sia presente in entrambe le tabelle
  % if ~any(strcmp(train_data.Properties.VariableNames, 'Label')) || ...
  %    ~any(strcmp(test_data.Properties.VariableNames, 'Label'))
  %     error('La colonna "Label" deve essere presente in entrambe le tabelle.');
  % end
  % controllo che le tabelle abbiane le stesse feature
  if ~isequal(train_data.Properties.VariableNames, test_data.Properties.VariableNames)
      error('Le tabelle di addestramento e test devono avere le stesse colonne.');
  end
  if n == 0
    train_selected = train_data;
    test_selected = test_data;
    selected_features = train_data.Properties.VariableNames;
    idx = 1:numel(selected_features);
    return;
  end

  feature_vars = varfun(@isnumeric, train_data, 'OutputFormat', 'uniform');
  feature_names = train_data.Properties.VariableNames(feature_vars & ~strcmp(train_data.Properties.VariableNames, 'Label'));

  % MRMR richiede solo feature numeriche
  train_features_only = train_data(:, [feature_names, {'Label'}]);
  [idx, ~] = fscmrmr(train_features_only, 'Label');

  % Numero di feature effettivamente disponibili
  num_available = numel(idx);
  n = min(n, num_available);

  % Prendo i nomi delle top-n feature
  selected_features = train_features_only.Properties.VariableNames(idx(1:n));

  % Aggiungo 'Label' in prima posizione
  selected_features = [{'Label'}, selected_features];

  % Seleziono colonne in entrambe le tabelle
  train_selected = train_data(:, selected_features);
  test_selected  = test_data(:, selected_features);
end
