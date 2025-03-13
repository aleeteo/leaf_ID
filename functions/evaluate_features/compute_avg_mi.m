function mi = compute_avg_mi(feature, labels)
    % Calcola l'informazione mutua tra una feature (continua)
    % e una variabile discreta (classe).
    %
    % Input:
    %   feature - Vettore delle features (continua o discreta)
    %   labels - Vettore delle classi corrispondenti (discrete)
    %
    % Output:
    %   mi - Informazione mutua I(X; Y)
    
    % Discretizzazione della feature continua
    % Numero di bin basato su Sturges' rule (https://www.statology.org/sturges-rule/)
    num_bins = round(sqrt(length(feature))); 
    feature_discrete = discretize(feature, num_bins);
    
    % Trovo le categorie uniche di feature e classi
    unique_features = unique(feature_discrete);
    unique_labels = unique(labels);
    
    % Calcolo le probabilità marginali
    p_x = histcounts(feature_discrete, num_bins, 'Normalization', 'probability'); % P(X)
    p_y = histcounts(labels, 'Normalization', 'probability'); % P(Y)
    
    % Calcolo la probabilità congiunta P(X, Y)
    p_xy = zeros(length(unique_features), length(unique_labels));
    for i = 1:length(unique_features)
        for j = 1:length(unique_labels)
            p_xy(i, j) = sum((feature_discrete == unique_features(i)) & (labels == unique_labels(j))) / length(feature);
        end
    end
    
    % Calcola l'informazione mutua I(X; Y)
    mi = 0;
    for i = 1:length(unique_features)
        for j = 1:length(unique_labels)
            if p_xy(i, j) > 0  % Evita log(0)
                mi = mi + p_xy(i, j) * log2(p_xy(i, j) / (p_x(i) * p_y(j)));
            end
        end
    end
end
