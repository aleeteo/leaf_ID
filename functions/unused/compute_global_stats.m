function stats = compute_global_stats(training_data)
  arguments
    training_data (:,:) table
  end

  data = training_data{:, 2:end}; % estrai i dati numerici (escludi la colonna label)
  variable_names = training_data.Properties.VariableNames(2:end); % prendi i nomi delle colonne 2+

  stats = table('size', [size(data, 2), 2], ...  % NB: righe = num colonne
               'VariableTypes', {'double', 'double'}, ...
               'VariableNames', {'mean', 'std'}, ...
               'RowNames', variable_names);

  % Calcolo statistiche
  stats.mean = mean(data, 1)';
  stats.std = std(data, 0, 1)';
end
