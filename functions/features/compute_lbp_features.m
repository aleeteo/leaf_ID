function [features, feature_names] = compute_lbp_features(img, mask)
  % funzione che calcola le features di LBP (estraendo dati di tipo numerico)
  % input: img = immagine in scala di grigi
  %        mask = maschera binaria
  % output: features = vettore con le features di LBP
  %         feature_names = vettore con i nomi delle features di LBP

  %conversione in scala di grigi
  if size(img,3) == 3
    img = rgb2gray(img);
  end
  
  % applicazione della maschera
  masked_img = img .* uint8(mask);

  features = extractLBPFeatures(masked_img,'NumNeighbors',8,'Radius',1,'Upright',true);
  feature_names = {'lbp'};
end
