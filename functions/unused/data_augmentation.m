function [img_augmented, mask_augmented] = data_augmentation(img, mask)
  % funzione che per ogni immagine restituisce un cell array di immagini
  % con risoluzione diversa e diversi bilanciamenti del bianco
  % input: img - immagine originale
  %        mask - maschera originale
  % output: img_augmented - cell array di immagini con risoluzione diversa
  %         mask_augmented - cell array di maschere con risoluzione diversa

  scales = [1, 0.2, 0.1]; % scale di riduzione
  n = numel(scales);
  img_augmented = cell(n, 1);
  mask_augmented = cell(n, 1);
  for i = 1:n
    img_augmented{i} = imresize(img, scales(i));
    mask_augmented{i} = imresize(mask, scales(i));
  end
end
