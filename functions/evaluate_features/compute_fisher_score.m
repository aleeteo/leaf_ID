function [fisher_score] = compute_fisher_score(feature, label)
  % funzione che calcola la metrica di Fisher Score
  % che indica la separabilia' delle classi secondo una feature
  % input: feature = vettore con le features
  %        label = vettore con i nomi delle features
  % output: fisher_score = metrica di Fisher Score
  % https://arxiv.org/abs/1202.3725

  classes = unique(label);
  num_classes = length(classes);
  N = length(feature);
  
  % Inizializza vettori
  mean_class = zeros(num_classes, 1);
  var_class = zeros(num_classes, 1);
  count_class = zeros(num_classes, 1);
  
  % Calcolo della media e varianza per classe
  for i = 1:num_classes
      idx = (label == classes(i));  % Indici della classe corrente
      count_class(i) = sum(idx);  % Numero di elementi per classe
      mean_class(i) = mean(feature(idx));  % Media della feature per classe
      var_class(i) = var(feature(idx), 0);  % Varianza della feature per classe
  end

  mean_global = sum(mean_class .* count_class) / N;
  num = sum(count_class .* (mean_class - mean_global).^2);
  denom = sum(count_class .* var_class);

  % Fisher Score
  fisher_score = num / denom;

  % Sostituisci NaN con zero (per evitare divisioni per zero)
  if isnan(fisher_score)
      fisher_score = 0;
  end

end

