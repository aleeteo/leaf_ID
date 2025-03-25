function [features, feature_names] = compute_edge_descriptors(mask)
  % Parametro per l'estrazione della signature (passo angolare)

  % Estrarre la firma del contorno utilizzando la funzione fornita
  signature = extract_polar_edge_signrature(mask, 'angle_step', 5, 'visualize', false);
  
  % Calcolare le feature richieste
  mean_val = mean(signature);                % Media
  var_val = var(signature);                  % Varianza
  kurt_val = kurtosis(signature);            % Curtosi
  % Entropia (aggiunto eps per evitare log(0))
  entropy_val = -sum(signature .* log2(signature + eps)); 

  % Creare array delle feature
  features = [mean_val, var_val, kurt_val, entropy_val];

  % Creare arraycell con i nomi delle feature
  feature_names = {'Media_edge', 'Varianza_edge', 'Curtosi_edge', 'Entropia_edge'};
end
