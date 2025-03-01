function outputImg = preprocessing(inputImg)
% Funzione che corregge l'esposizione di un'immagine, applica il bilanciamento
% del bianco con il metodo Grey World e ridimensiona l'immagine con un fattore di scala 0.3.
% Lo scopo è quello di rendere gestibili le foto originali per la
% generazione del dataset.

% Se l'input è un percorso, carica l'immagine
if ischar(inputImg)
  img = imread(inputImg);
else
  img = inputImg;
end

% Bilanciamento del bianco (Grey World)
meanRGB = mean(reshape(img, [], 3), 1); % Calcola la media dei canali R, G, B
greyMean = mean(meanRGB); % Valore medio del grigio ideale
scaleFactors = greyMean ./ meanRGB; % Fattore di correzione per ogni canale
imgWhiteBalanced = uint8(min(255, double(img) .* reshape(scaleFactors, 1, 1, 3))); % Applica il bilanciamento

% Converti in spazio Lab per regolare solo la luminosità
labImg = rgb2lab(imgWhiteBalanced);
L = labImg(:,:,1) / 100; % Normalizza canale L
L = imadjust(L, stretchlim(L, [0.00 0.98])); % Meno aggressivo sulle ombre
labImg(:,:,1) = L * 100; % Riporta il canale L alla scala originale
imgAdjusted = lab2rgb(labImg);

% Ridimensionamento a risoluzione 1300x1040 (circa 0.3 della risoluzione originale)
outputImg = imresize(imgAdjusted, [1041 1300]);

% Visualizza l'immagine elaborata
% imshow(outputImg);
end
