function [images, masks, labels] = readlists()
  f = fopen('dataset/01_train/images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:}; 

  f = fopen('dataset/01_train/labels_general.list');
  l = textscan(f,'%s');
  labels = l{:};
  fclose(f);

  f = fopen('dataset/01_train/masks.list');
  m = textscan(f,'%s');
  masks = m{:};
  fclose(f);
end
