function f1 = compute_f1_score(true_labels, predicted_labels)
%COMPUTE_F1_SCORE Calcola F1 macro tra etichette vere e predette
%   true_labels: vettore delle etichette reali
%   predicted_labels: vettore delle etichette predette
%   Ritorna: F1 macro (media delle F1 per classe)

  classes = categories(true_labels);  % Tutte le classi
  nClasses = numel(classes);
  f1s = zeros(nClasses, 1);

  for i = 1:nClasses
    class = classes{i};

    tp = sum(predicted_labels == class & true_labels == class);
    fp = sum(predicted_labels == class & true_labels ~= class);
    fn = sum(predicted_labels ~= class & true_labels == class);

    if tp + fp == 0
      precision = 0;
    else
      precision = tp / (tp + fp);
    end

    if tp + fn == 0
      recall = 0;
    else
      recall = tp / (tp + fn);
    end

    if precision + recall == 0
      f1s(i) = 0;
    else
      f1s(i) = 2 * (precision * recall) / (precision + recall);
    end
  end

  f1 = mean(f1s);  % Macro average
end
