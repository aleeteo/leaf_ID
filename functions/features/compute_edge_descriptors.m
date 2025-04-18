function [features, feature_names] = compute_edge_descriptors(mask)
  % Parametro per l'estrazione della signature (passo angolare)

  % Estrarre la firma del contorno utilizzando la funzione fornita
  signature = extract_polar_edge_signature(mask);
  
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

function signature = extract_polar_edge_signature(mask, varargin)
  % extract_polar_edge_signature  Estrae la firma polare di una foglia da una maschera binaria.
  %
  %   signature = extract_polar_edge_signature(mask)
  %       Estrae la firma polare normalizzata del contorno della foglia 
  %       rappresentata da una maschera binaria (valori logici true/false).
  %       La firma è invariante alla rotazione e normalizzata in scala.
  %
  %   signature = extract_polar_edge_signature(mask, 'Name', Value, ...)
  %       Permette di specificare opzioni aggiuntive tramite coppie nome/valore.
  %
  %   Parametri opzionali:
  %     'angle_step'   - Ampiezza del passo angolare in radianti (default: pi/36, cioè 5°)
  %     'visualize'    - Se true, visualizza il contorno e la firma (default: false)
  %     'smoothing'    - Applica un filtro di smoothing alla firma (default: true)
  %
  %   Output:
  %     signature      - Vettore double contenente la distanza normalizzata dal baricentro
  %                      della foglia rispetto ad angoli regolari in [0, 2*pi)
  %
  %   Esempio:
  %     mask = imread('leaf_mask.png') > 0;
  %     sig = extract_polar_edge_signature(mask, 'angle_step', pi/18, 'visualize', true);
  %
  %   Note:
  %     - La funzione usa binning angolare per stabilità e robustezza.
  %     - La firma è automaticamente shiftata per essere invariante alla rotazione.

  %% --- Parametri opzionali ---
  p = inputParser;
  addParameter(p, 'angle_step', pi/36, @(x) isnumeric(x) && x > 0 && x <= 2*pi); % default = 5°
  addParameter(p, 'visualize', false, @(x) islogical(x) || (isnumeric(x) && (x == 0 || x == 1)));
  addParameter(p, 'smoothing', true, @(x) islogical(x));
  parse(p, varargin{:});

  angle_step = p.Results.angle_step;
  visualize = p.Results.visualize;
  smoothing = p.Results.smoothing;

  %% --- 1. Estrai il contorno della foglia ---
  edges = bwperim(mask);
  [y, x] = find(edges);

  %% --- 2. Calcola il baricentro ---
  centroid = [mean(x), mean(y)];

  %% --- 3. Coordinate polari ---
  angles = mod(atan2(y - centroid(2), x - centroid(1)), 2*pi); % [0, 2pi)
  distances = sqrt((x - centroid(1)).^2 + (y - centroid(2)).^2);

  %% --- 4. Binning delle distanze per angolo ---
  bins = 0:angle_step:(2*pi - angle_step);
  binned_distances = zeros(size(bins));
  for i = 1:length(bins)
    in_bin = angles >= bins(i) & angles < bins(i) + angle_step;
    if any(in_bin)
      binned_distances(i) = mean(distances(in_bin));
    else
      binned_distances(i) = NaN;
    end
  end

  %% --- 5. Interpolazione per riempire eventuali NaN ---
  if any(isnan(binned_distances))
    binned_distances = fillmissing(binned_distances, 'linear', 'EndValues', 'nearest');
  end

  %% --- 6. Smoothing opzionale ---
  if smoothing
    binned_distances = movmean(binned_distances, 3);
  end

  %% --- 7. Normalizzazione (scala) ---
  signature = binned_distances / max(binned_distances);

  %% --- 8. Invarianza alla rotazione (circolarmente shiftato)
  [~, max_idx] = max(signature);
  signature = circshift(signature, -max_idx + 1);

  %% --- 9. Visualizzazione ---
  if visualize
    figure;
    subplot(1,2,1); imshow(edges); title('Contorno Estratto');

    subplot(1,2,2); 
    plot(bins, signature, '-o');
    xlabel('Angolo (rad)'); ylabel('Distanza Normalizzata');
    title('Firma in radianti - Invariante alla Rotazione');
    xlim([0, 2*pi]); grid on;
  end
end
