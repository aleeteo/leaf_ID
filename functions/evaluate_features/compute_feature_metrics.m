function [metrics] = compute_feature_metrics(data, features_name)
  % genera una tabella contenente varie metriche di misurazione della bonta'
  % e normalizza le metriche  
  % delle features estratte da un dataset
  % input: feature = vettore con le features
  %        label = vettore con i nomi delle features
  % output: metrics = tabella con le metriche di misurazione della bonta'

  labels = data(:,1);
  features = data(:, 2:end);
  n_features = size(features, 2);
  features_name = features_name(2:end)';

  fisher_score = zeros(n_features, 1);
  avg_bhattacharyya = zeros(n_features, 1);
  % avg_mutual_info = zeros(n_features, 1);

  for i = 1:n_features
    fisher_score(i) = compute_fisher_score(features(:, i), labels);
    avg_bhattacharyya(i) = compute_avg_bhattacharyya(features(:, i), labels);
    % avg_mutual_info(i) = compute_avg_mi(features(:, i), labels);
  end

  norm_fisher_score = fisher_score ./ max(fisher_score);
  norm_avg_bhattacharyya = avg_bhattacharyya ./ max(avg_bhattacharyya);

  metrics = table(features_name, fisher_score, avg_bhattacharyya, norm_fisher_score, norm_avg_bhattacharyya, ...
    'VariableNames', {'Feature', 'Fisher', 'Bhattacharyya', 'norm_fisher', 'norm_bhat'});
end
