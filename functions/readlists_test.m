function [images, masks, labels] = readlists_test()
  f = fopen('dataset/02_test/images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:}; 

  f = fopen('dataset/02_test/masks.list');
  m = textscan(f,'%s');
  masks = m{:};
  fclose(f);

  f = fopen('dataset/02_test/labelsNumeric.list');
  l = textscan(f,'%s');
  labels = l{:};
  fclose(f);
end
