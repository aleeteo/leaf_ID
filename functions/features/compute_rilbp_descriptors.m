function [features, feature_names] = compute_rilbp_descriptors(img, mask)
% COMPUTE_RILBP_DESCRIPTORS  Calcola i descrittori LBP rotation-invariant.
%
%   [features, feature_names] = COMPUTE_RILBP_DESCRIPTORS(img, mask)
%   restituisce un istogramma LBP uniforme (8,1) calcolato sulla bounding
%   box della regione mascherata. L'istogramma è normalizzato a somma 1.
%
%   INPUT
%     img  : immagine (grayscale uint8) – se RGB viene convertita in gray
%     mask : maschera logica dell’oggetto di interesse
%
%   OUTPUT
%     features      : vettore riga con le 59 bin dell’LBP rotation-invariant
%     feature_names : cell array con i nomi delle feature
%
%   Richiede la Computer Vision Toolbox (funzione extractLBPFeatures).

  arguments
    img  (:,:,:) uint8
    mask (:,:)   logical
  end

  if size(img,3) ~= 1
      img = rgb2gray(img);
  end

  % estrazione dell bounding box della regione mascherata
  props = regionprops(mask, 'BoundingBox');
  if isempty(props)
      % Nessuna regione → restituisci NaN per coerenza con le altre funzioni
      features = nan(1,59);
      feature_names = arrayfun(@(i) sprintf('texture.rilbp_%02d',i), ...
                               1:59, 'UniformOutput', false);
      return
  end

  bb = round(props(1).BoundingBox);             % [x y w h]
  x1 = max(1, bb(1));           y1 = max(1, bb(2));
  x2 = min(size(img,2), x1+bb(3)-1);
  y2 = min(size(img,1), y1+bb(4)-1);

  roi = img(y1:y2, x1:x2);

  % -- LBP uniforme, raggio 1, 8 vicini, rotation-invariant --------------
  % Upright=false → invarianti alla rotazione
  lbp_hist = extractLBPFeatures(roi, ...
                 'NumNeighbors', 8, ...
                 'Radius',       1, ...
                 'Upright',      false, ...
                 'Normalization','None' );   % restituisce 59 bin

  features = lbp_hist;
  feature_names = arrayfun(@(i) sprintf('texture.rilbp_%02d',i), ...
                           1:numel(lbp_hist), 'UniformOutput', false);
end
