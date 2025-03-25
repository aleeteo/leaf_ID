function [metrics] = compute_feature_metrics(data)
  % genera una tabella contenente varie metriche di misurazione della bonta'
  % delle features estratte da un dataset e normalizza le metriche
  % input: data = table (prima colonna: Label, resto: features numeriche)
  % output: metrics = tabella con le metriche per ogni feature

  %%% CAMBIATO: accede direttamente alla colonna Label come vettore
  labels = data.Label;  
  features = data(:, 2:end);
  n_features = size(features, 2);
  feature_names = data.Properties.VariableNames(2:end);

  fisher_score = zeros(n_features, 1);
  avg_bhattacharyya = zeros(n_features, 1);
  % avg_mutual_info = zeros(n_features, 1);  % lasciata commentata se vuoi aggiungerla dopo

  for i = 1:n_features
    %%% CAMBIATO: estrai il contenuto numerico della colonna table
    feature_vector = features{:, i};  % vettore numerico
    fisher_score(i) = compute_fisher_score(feature_vector, labels);
    avg_bhattacharyya(i) = compute_avg_bhattacharyya(feature_vector, labels);
  end

  %%% CAMBIATO: gestione divisione per zero in normalizzazione
  norm_fisher_score = fisher_score ./ max(fisher_score + eps);
  norm_avg_bhattacharyya = avg_bhattacharyya ./ max(avg_bhattacharyya + eps);

  metrics = table(feature_names', fisher_score, avg_bhattacharyya, ...
                  norm_fisher_score, norm_avg_bhattacharyya, ...
    'VariableNames', {'Feature', 'Fisher', 'Bhattacharyya', 'norm_fisher', 'norm_bhat'});
end

function [fisher_score] = compute_fisher_score(feature, label)
  % Fisher score: separabilità tra classi per una singola feature

  %%% CAMBIATO: label è già vettore -> non serve label{:,1}
  classes = unique(label);
  num_classes = numel(classes);
  N = numel(feature);
  
  mean_class = zeros(num_classes, 1);
  var_class = zeros(num_classes, 1);
  count_class = zeros(num_classes, 1);
  
  for i = 1:num_classes
    %%% CAMBIATO: confronto diretto, label è vettore
    idx = (label == classes(i));
    count_class(i) = sum(idx);
    mean_class(i) = mean(feature(idx));
    var_class(i) = var(feature(idx), 0);  % varianza non campionaria
  end

  mean_global = sum(mean_class .* count_class) / N;
  num = sum(count_class .* (mean_class - mean_global).^2);
  denom = sum(count_class .* var_class);

  fisher_score = num / (denom + eps);  % eps evita divisione per 0

  if isnan(fisher_score)
      fisher_score = 0;
  end
end

function avg_bhattacharyya = compute_avg_bhattacharyya(feature, labels)
  % Distanza media di Bhattacharyya tra tutte le coppie di classi
  
  classes = unique(labels);
  n_classes = numel(classes);
  bhattacharyya = zeros(nchoosek(n_classes, 2), 1);
  count = 1;

  for i = 1:n_classes
    for j = i+1:n_classes
      bhat = compute_bhattacharyya(feature, labels, classes(i), classes(j));  % %%% CAMBIATO: passa classi
      bhattacharyya(count) = bhat;
      count = count + 1;
    end
  end

  avg_bhattacharyya = mean(bhattacharyya);

  function bhat = compute_bhattacharyya(feature, labels, classP, classQ)
      %%% CAMBIATO: ora classP e classQ sono valori reali
      idxP = (labels == classP);
      idxQ = (labels == classQ);
      meanP = mean(feature(idxP));
      meanQ = mean(feature(idxQ));
      varP = var(feature(idxP), 0);
      varQ = var(feature(idxQ), 0);

      %%% CAMBIATO: protezione da varianza nulla (divisione per 0/log di 0)
      varP = varP + eps;
      varQ = varQ + eps;

      b1 = ((meanP - meanQ)^2) / (4 * (varP + varQ));
      b2 = 0.5 * log((varP + varQ) / (2 * sqrt(varP * varQ)));
      bhat = b1 + b2;
  end
end

