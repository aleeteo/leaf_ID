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
labels = ["classe 1", "classe 2", "classe 3", "classe 4", "classe 5", ...
             "classe 6", "classe 7", "classe 8", "classe 9", "classe 10"];

template = struct('label', categorical("", labels), ...
                  'masks', [], ...
                  'image', []);

classes_train = repmat(template, 1, 10);
classes_test = repmat(template, 1, 10);


for i = 1:10
  %caricamento della maschera di classi
  class_mask = imread(masks{i});
  classes_train(i).label = categorical(labels(i), labels);
  classes_test(i).label  = categorical(labels(i), labels);
  classes_train(i).image = imread(images{i});
  classes_test(i).image = imread(images{i});
  [components, num] = bwlabel(class_mask);
  
  % estrazione dei soli primi 10 elementi della maschera
  for j = 1:10
    mask = components == j;
    classes_train(i).masks{j} = mask;
  end
  %estrazione degli ultimi 5 elementi della maschera
  for j = 11:num
    mask = components == j;
    classes_train(i).masks{j-10} = mask;
  end
end

% salvo la struct
save('dataset/03_classes/mask_structs.mat', 'classes_train', 'classes_test');

clear
