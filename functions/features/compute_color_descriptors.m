function [features, feature_names] = compute_color_descriptors(img, mask)
  % Controllo input
  if nargin < 2
      error('Devi fornire un''immagine e una maschera binaria.');
  end
  if size(img,3) ~= 3
      error('L''immagine deve essere RGB.');
  end
  
  % Converte l'immagine in double
  img = im2double(img);
  
  % TODO: ottimizzare applicazione maschera
  
  % Assicura che la maschera sia binaria
  mask = mask > 0;

  % Converte in LAB e HSV
  labImg = rgb2lab(img);
  hsvImg = rgb2hsv(img);

  % Seleziona solo i pixel validi della maschera
  valid_pixels_RGB = img(repmat(mask, [1, 1, 3])); % Estrai solo i pixel validi in RGB
  valid_pixels_LAB = labImg(repmat(mask, [1, 1, 3])); % Estrai solo i pixel validi in LAB
  valid_pixels_HSV = hsvImg(repmat(mask, [1, 1, 3])); % Estrai solo i pixel validi in HSV

  % Ridimensiona in un formato Nx3 per il calcolo statistico
  valid_pixels_RGB = reshape(valid_pixels_RGB, [], 3);
  valid_pixels_LAB = reshape(valid_pixels_LAB, [], 3);
  valid_pixels_HSV = reshape(valid_pixels_HSV, [], 3);

  % Rimuove eventuali righe nulle (causate da reshape su una maschera completamente nera)
  valid_pixels_RGB = valid_pixels_RGB(any(valid_pixels_RGB, 2), :);
  valid_pixels_LAB = valid_pixels_LAB(any(valid_pixels_LAB, 2), :);
  valid_pixels_HSV = valid_pixels_HSV(any(valid_pixels_HSV, 2), :);

  % Calcolo delle medie
  meanRed = mean(valid_pixels_RGB(:, 1));
  meanGreen = mean(valid_pixels_RGB(:, 2));
  meanBlue = mean(valid_pixels_RGB(:, 3));
  meanHue = mean(valid_pixels_HSV(:, 1));
  meanSaturation = mean(valid_pixels_HSV(:, 2));
  meanValue = mean(valid_pixels_HSV(:, 3));
  meanL = mean(valid_pixels_LAB(:, 1));
  meanA = mean(valid_pixels_LAB(:, 2));
  meanB = mean(valid_pixels_LAB(:, 3));

  % Calcolo delle varianze
  varRed = var(valid_pixels_RGB(:, 1));
  varGreen = var(valid_pixels_RGB(:, 2));
  varBlue = var(valid_pixels_RGB(:, 3));
  varHue = var(valid_pixels_HSV(:, 1));
  varSaturation = var(valid_pixels_HSV(:, 2));
  varValue = var(valid_pixels_HSV(:, 3));
  varL = var(valid_pixels_LAB(:, 1));
  varA = var(valid_pixels_LAB(:, 2));
  varB = var(valid_pixels_LAB(:, 3));

  % Creazione vettore con le features
  features = [meanRed, meanGreen, meanBlue, meanHue, meanSaturation, meanValue, ...
              meanL, meanA, meanB, varRed, varGreen, varBlue, varHue, varSaturation, varValue, ...
              varL, varA, varB];

  feature_names = {'meanRed', 'meanGreen', 'meanBlue', 'meanHue', ...
                   'meanSaturation', 'meanValue', 'meanL', 'meanA', 'meanB', ...
                   'varRed', 'varGreen', 'varBlue', 'varHue', ...
                   'varSaturation', 'varValue', 'varL', 'varA', 'varB'};
end
