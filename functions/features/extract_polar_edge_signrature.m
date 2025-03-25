function signature = extract_polar_edge_signrature(mask, varargin)
  % funzione che calcola la firma polare dell'edge della foglia

  % test di dell'input parser per paramentri opzionali
  p = inputParser;
  addParameter(p, 'angle_step', 5, @(x) isnumeric(x) && x>=0 && x<=360);
  addParameter(p, 'visualize', false, @(x) islogical(x) || ...
                                      (isnumeric(x) && (x == 0 || x == 1)));
  parse(p, varargin{:});

  angle_step = p.Results.angle_step;
  visualize = p.Results.visualize;

  
  % 1. Estrarre il contorno della foglia
  edges = bwperim(mask);

  % 2. Ottenere coordinate dei punti di bordo
  [y, x] = find(edges);

  % 3. Calcolare il baricentro
  centroid = [mean(x), mean(y)];

  % 4. Convertire in coordinate polari rispetto al baricentro
  angles = atan2(y - centroid(2), x - centroid(1)); % Angoli in radianti
  distances = sqrt((x - centroid(1)).^2 + (y - centroid(2)).^2); % Distanze dal baricentro

  % 5. Convertire angoli in gradi e ordinare i punti
  angles_deg = rad2deg(angles);
  [angles_deg, sort_idx] = sort(mod(angles_deg, 360)); % Assicura che siano tra 0° e 360°
  distances = distances(sort_idx);

  % 6. Definire la griglia di campionamento ad angoli regolari (es. ogni 5°)
  sampled_angles = 0:angle_step:355; % Angoli da 0° a 355°
  
  % 7. Interpolare le distanze sui nuovi angoli
  signature = interp1(angles_deg, distances, sampled_angles, 'linear', 'extrap');

  % 8. Normalizzazione per invarianza alla scala
  % signature = (signature - min(signature)) / (max(signature) - min(signature)); % Normalizza tra 0 e 1
  signature = signature / max(signature); % Normalizza tra 0 e 1

  % 9. Visualizzazione
  if visualize == true
    figure;
    subplot(1,2,1); imshow(edges); title('Contorno Estratto');
    subplot(1,2,2); plot(sampled_angles, signature, '-o'); 
    xlabel('Angolo (°)'); ylabel('Distanza Normalizzata');
    title('Firma Campionata ad Angoli Regolari');
  end
end
