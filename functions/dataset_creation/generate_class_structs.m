% Lo scopo di questo script è quello di generare le maschere di training
% che potranno essere utilizzate insieme alle classi per l'addestramento
% di un classificatore.

clear
close all

% lettura del file list con i path delle maschere globali
% e le immagini delle classi
f = fopen('dataset/03_classes/images.list');
z = textscan(f,'%s');
fclose(f);
images = z{:}; 

f = fopen('dataset/03_classes/masks.list');
m = textscan(f,'%s');
masks = m{:};
fclose(f);

[rows, cols, ch] = size(imread(images{1}));

% prealloca la struct
labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

template = struct('label', categorical("", labels), ...
                  'masks', [], ...
                  'image', []);

classes = repmat(template, 1, 10);


for i = 1:10
  %caricamento della maschera di classi
  class_mask = imread(masks{i});
  classes(i).label = categorical(labels(i), labels);
  classes(i).image = imread(images{i});
  [components, num] = bwlabel(class_mask);
  
  % estrazione dei soli primi 10 elementi della maschera
  for j = 1:num
    mask = components == j;
    classes(i).masks{j} = mask;
  end
end

% salvo la struct
save("data/classes_structs.mat", "classes");

clear
