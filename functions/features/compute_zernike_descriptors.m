function [zernike_feats, feat_names] = compute_zernike_descriptors(img, mask, n_max)
% COMPUTE_ZERNIKE_DESCRIPTORS Calcola i momenti di Zernike fino a ordine n_max.
%
%   [zernike_feats, feat_names] = COMPUTE_ZERNIKE_DESCRIPTORS(img, mask, n_max)
%   img: immagine in scala di grigi (uint8 o double)
%   mask: maschera binaria della regione
%   n_max: ordine massimo dei momenti di Zernike
%
%   Output:
%     zernike_feats: vettore con i moduli dei momenti (invarianti alla rotazione)
%     feat_names: cell array con i nomi delle feature (e.g. 'zernike_n4_m2')

  % Converti in double se necessario
  if ~isa(img, 'double')
      img = double(img);
  end

  % Estrai bounding box e ridimensiona
  stats = regionprops(mask, 'BoundingBox');
  bbox = round(stats(1).BoundingBox);
  sub_img = imcrop(img, bbox);
  sub_mask = imcrop(mask, bbox);

  % Ridimensiona a immagine quadrata (es. 128x128)
  N = 128;
  sub_img = imresize(sub_img, [N N]);
  sub_mask = imresize(sub_mask, [N N], 'nearest'); % preserva la maschera binaria
  sub_mask = sub_mask > 0.5; % assicura tipo logico

  % Coordinate normalizzate su disco unitario
  [X, Y] = meshgrid(linspace(-1, 1, N));
  R = sqrt(X.^2 + Y.^2);
  Theta = atan2(Y, X);

  % Applica la maschera e normalizza l'intensità
  region = sub_img .* sub_mask;
  region = region / max(region(:)); % Normalizza in [0,1]

  % Calcolo momenti
  zernike_feats = [];
  feat_names = {};

  for n = 0:n_max
    for m = -n:2:n
      if mod(n - abs(m), 2) == 0
        Vnm = compute_single_zernike(region, R, Theta, sub_mask, n, m);
        zernike_feats(end+1) = abs(Vnm);
        feat_names{end+1} = sprintf('zernike_n%d_m%d', n, m);
      end
    end
  end
end

function Vnm = compute_single_zernike(region, R, Theta, mask, n, m)
% Calcola il momento Zernike (n,m) su disco unitario

  radial = radial_poly(n, abs(m), R);
  Vnm_kernel = radial .* exp(-1i * m * Theta);
  Vnm_kernel(R > 1) = 0; % Fuori dal disco unitario
  valid_pixels = mask & (R <= 1); % assicura all’interno del disco e della maschera
  Vnm = sum(region(valid_pixels) .* Vnm_kernel(valid_pixels)) * (n + 1) / pi;
end

function Rnm = radial_poly(n, m, R)
% Calcolo dei polinomi radiali R_{n}^{m}(r)
  Rnm = zeros(size(R));
  for s = 0:((n - m)/2)
    c = ((-1)^s) * factorial(n - s) / ...
        (factorial(s) * factorial((n + m)/2 - s) * factorial((n - m)/2 - s));
    Rnm = Rnm + c * R.^(n - 2*s);
  end
end
