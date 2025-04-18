function [features, feature_names] = compute_shape_descriptors(img, mask)
    % Controllo input
    if nargin < 1
        error('Devi fornire una maschera binaria.');
    end
    
    % Etichettatura della regione connessa nella maschera
    stats = regionprops(mask, 'Area', 'Perimeter', 'Eccentricity');

    % Controllo che la maschera contenga almeno un oggetto
    if isempty(stats)
        error('La maschera non contiene oggetti validi.');
    end
    
    % Estrazione delle proprietà
    area = stats.Area;
    perimetro = stats.Perimeter;
    eccentricity = stats.Eccentricity;
    
    % Calcolo compattezza e circolarità
    compactness = (perimetro^2) / area;
    circularity = (4 * pi * area) / (perimetro^2);

    hu = compute_hu_moments(mask);
    hu_names = {'HuMoment1', 'HuMoment2', 'HuMoment3', 'HuMoment4', ...
                'HuMoment5', 'HuMoment6', 'HuMoment7'};
    hu_gray = compute_hu_moments(mask, img);
    hu_gray_names = {'Hu_gray_1', 'Hu_gray_2', 'Hu_gray_3', 'Hu_gray_4', ...
                     'Hu_gray_5', 'Hu_gray_6', 'Hu_gray_7'};
    
    % Creazione del vettore delle features
    features = [compactness, circularity, eccentricity, ...
                hu, hu_gray];
    
    % Creazione del vettore dei nomi delle features
    feature_names = [{'Compactness', 'Circularity', 'Eccentricity'}, ...
                     hu_names, hu_gray_names];
end

function hu = compute_hu_moments(mask, image, max_order)
  % COMPUTE_HU_MOMENTS Calcola i momenti di Hu di un'immagine o maschera.
  %
  % USO:
  %   hu = compute_hu_moments(mask)
  %   hu = compute_hu_moments(mask, image)
  %   hu = compute_hu_moments(mask, image, max_order)
  %
  % INPUT:
  %   - mask:      Matrice binaria che definisce la regione di interesse (obbligatorio).
  %   - image:     Immagine originale (opzionale, default = []).
  %   - max_order: Numero massimo di momenti di Hu da calcolare (opzionale, default = 7).
  %
  % OUTPUT:
  %   - hu: Vettore contenente i momenti di Hu fino a max_order.
  %
  % ESEMPIO:
  %   mask = imread('mask.png'); 
  %   image = imread('image.png'); 
  %   hu = compute_hu_moments(mask, image, 5);

  % arguments invece di inputParser per migliorare integrazione con matlab
  arguments
    mask (:,:) double
    image (:,:,:) double = []
    max_order (1,1) double {mustBeInteger, mustBePositive, ...
                            mustBeLessThanOrEqual(max_order, 7)} = 7
  end

  % Se è presente l'immagine applica la maschera
  if ~isempty(image)
    if size(image, 3) ~= 1
      image = rgb2gray(image);
    end
    img = double(image) .* mask;
  else
    img = mask;
  end

  % Ottieni la dimensione dell'immagine
  [rows, cols] = size(img);
  [X, Y] = meshgrid(1:cols, 1:rows);

  % Calcola i momenti spaziali
  m00 = sum(img(:));
  if m00 == 0
    hu = zeros(1, max_order);
    return;
  end
  m10 = sum(sum(X .* img));
  m01 = sum(sum(Y .* img));

  % Calcola il centroide
  xc = m10 / m00;
  yc = m01 / m00;

  % Calcola i momenti centrali fino all'ordine massimo specificato
  mu20 = sum(sum(((X - xc).^2) .* img));
  mu02 = sum(sum(((Y - yc).^2) .* img));
  mu11 = sum(sum(((X - xc) .* (Y - yc)) .* img));

  if max_order >= 3
    mu30 = sum(sum(((X - xc).^3) .* img));
    mu03 = sum(sum(((Y - yc).^3) .* img));
    mu21 = sum(sum(((X - xc).^2 .* (Y - yc)) .* img));
    mu12 = sum(sum(((X - xc) .* (Y - yc).^2) .* img));
  end

  % Calcola i momenti centrali normalizzati
  eta20 = mu20 / m00^2;
  eta02 = mu02 / m00^2;
  eta11 = mu11 / m00^2;

  if max_order >= 3
    eta30 = mu30 / m00^(2.5);
    eta03 = mu03 / m00^(2.5);
    eta21 = mu21 / m00^(2.5);
    eta12 = mu12 / m00^(2.5);
  end

  % Calcola i momenti di Hu fino a max_order
  hu = zeros(1, max_order);
  hu(1) = eta20 + eta02;
  if max_order >= 2
    hu(2) = (eta20 - eta02)^2 + 4 * eta11^2;
  end
  if max_order >= 3
    hu(3) = (eta30 - 3 * eta12)^2 + (3 * eta21 - eta03)^2;
  end
  if max_order >= 4
    hu(4) = (eta30 + eta12)^2 + (eta21 + eta03)^2;
  end
  if max_order >= 5
    hu(5) = (eta30 - 3 * eta12) * (eta30 + eta12) * ((eta30 + eta12)^2 - 3 * (eta21 + eta03)^2) + ...
            (3 * eta21 - eta03) * (eta21 + eta03) * (3 * (eta30 + eta12)^2 - (eta21 + eta03)^2);
  end
  if max_order >= 6
    hu(6) = (eta20 - eta02) * ((eta30 + eta12)^2 - (eta21 + eta03)^2) + ...
            4 * eta11 * (eta30 + eta12) * (eta21 + eta03);
  end
  if max_order >= 7
    hu(7) = (3 * eta21 - eta03) * (eta30 + eta12) * ((eta30 + eta12)^2 - 3 * (eta21 + eta03)^2) - ...
            (eta30 - 3 * eta12) * (eta21 + eta03) * (3 * (eta30 + eta12)^2 - (eta21 + eta03)^2);
  end
end
