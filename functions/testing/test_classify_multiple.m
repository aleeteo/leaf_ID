clear
close all


f = fopen('dataset/03_classes/images.list');
z = textscan(f,'%s');
fclose(f);
images = z{:}; 

f = fopen('dataset/03_classes/masks.list');
m = textscan(f,'%s');
masks = m{:};
fclose(f);

f = fopen('dataset/03_classes/labels.list');
l = textscan(f,'%s');
labels = l{:};
fclose(f);

clear z m l f

for i = 1:numel(images)
  img = imread(images{i});
  mask = imread(masks{i});
  label = load(labels{i}).labeledImage;
  
  pred = classify_multiple(img, mask);

  confmat = confusionmat(label(:), pred(:));
  figure;
  subplot(1,2,1), imagesc(pred);
  subplot(1,2,2), confusionchart(abs(confmat), 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized'), title('Confusion Matrix');

  correct = sum((label(:) == pred(:)) & (pred(:) ~= 0));
  total = nnz(pred(:) ~= 0);
  accuracy = correct / total;
  disp(['Accuracy: ', num2str(accuracy)]);
end
