% Lo scopo di questo script è quello di generare le maschere di training
% che potranno essere utilizzate insieme alle classi per l'addestramento
% di un classificatore.

clear
close all

images = getFilePaths('dataset/04_unknown_class/images');
masks = getFilePaths('dataset/04_unknown_class/masks');

[rows, cols, ch] = size(imread(images{1}));

% prealloca la struct
% labels = ["11", "11", "11"];

template = struct('label', categorical(""), ...
                  'masks', [], ...
                  'image', []);

unknown_structs = repmat(template, 1, 3);


for i = 1:3
  %caricamento della maschera di classi
  class_mask = imread(masks{i});
  unknown_structs(i).label = categorical("11");
  unknown_structs(i).image = imread(images{i});
  [components, num] = bwlabel(class_mask);
  
  % estrazione dei soli primi 10 elementi della maschera
  for j = 1:num
    mask = components == j;
    unknown_structs(i).masks{j} = mask;
  end
end

% salvo la struct
save("data/unknown_structs.mat", "unknown_structs");

clear
