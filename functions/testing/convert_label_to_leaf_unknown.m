function data = convert_label_to_leaf_unknown(data)
%CONVERT_LABEL_TO_LEAF_UNKNOWN Rietichetta i dati da numerici a 'leaf'/'unknown'.
%   Prende una tabella con colonna 'Label' (numeric o categorical) e la converte
%   in etichette testuali 'leaf' per classi 1–10 e 'unknown' per 11.

  if ~any(strcmp(data.Properties.VariableNames, "Label"))
    error("La tabella deve contenere una colonna 'Label'");
  end

  % Converte Label in double se necessario (gestisce categorical o numeric)
  numeric_labels = double(data.Label);

  % Inizializza le nuove etichette come 'leaf'
  new_labels = repmat("leaf", height(data), 1);

  % Assegna 'unknown' dove il label è 11
  new_labels(numeric_labels == 11) = "unknown";

  % Riassegna alla colonna 'Label' della tabella
  data.Label = categorical(new_labels);
end
