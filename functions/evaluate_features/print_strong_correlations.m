function print_strong_correlations(cm_table, threshold)
  % Stampa le coppie di variabili con |correlazione| > threshold
  % INPUT:
  %   - cm_table: matrice di correlazione come table (con RowNames e VariableNames)
  %   - threshold: valore soglia per la correlazione (es. 0.9)

  % Estrarre matrice numerica e nomi delle variabili
  mat = abs(cm_table{:,:});
  names = cm_table.Properties.VariableNames;

  % Creare maschera logica per la parte triangolare superiore
  mask = triu(mat > threshold, 1);

  % Trovare le coppie di indici
  [row_idx, col_idx] = find(mask);

  % Stampare le coppie con il valore originale della correlazione (non assoluto)
  if isempty(row_idx)
    fprintf('Nessuna coppia con correlazione > %.2f trovata.\n', threshold);
  else
    fprintf('Coppie con |correlazione| > %.2f:\n', threshold);
    for k = 1:length(row_idx)
      i = row_idx(k);
      j = col_idx(k);
      corr_val = cm_table{i, j};
      fprintf('  %s - %s | Corr = %.3f\n', names{i}, names{j}, corr_val);
    end
  end
end
