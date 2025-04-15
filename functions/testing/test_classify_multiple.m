function acc = test_classify_multiple(C, minmax, images, masks, labels)
  arguments
    C
    minmax
    images cell
    masks cell
    labels cell
  end

  % default su directory delle classi se le liste non sono fornite
  if isempty(images)
    f = fopen('dataset/03_classes/images.list');
    z = textscan(f,'%s');
    fclose(f);
    images = z{:}; 
  end
  if isempty(masks)
    f = fopen('dataset/03_classes/masks.list');
    z = textscan(f,'%s');
    fclose(f);
    masks = z{:}; 
  end
  if isempty(labels)
    f = fopen('dataset/03_classes/labels.list');
    z = textscan(f,'%s');
    fclose(f);
    labels = z{:}; 
  end

  clear z m l f
  acc = 0;

  for i = 1:numel(images)
    img = imread(images{i});
    mask = imread(masks{i});
    label = load(labels{i}).labeledImage;
    
    pred = classify_multiple(img, mask, C, minmax);

    confmat = confusionmat(label(:), pred(:));
    figure;
    subplot(1,2,1), imagesc(pred);
    subplot(1,2,2), confusionchart(abs(confmat), 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized'), title('Confusion Matrix');

    correct = sum((label(:) == pred(:)) & (pred(:) ~= 0));
    total = nnz(pred(:) ~= 0);
    accuracy = correct / total;
    acc = acc + accuracy;
    disp(['Accuracy: ', num2str(accuracy)]);
  end

  acc = acc / numel(images);
  disp(['Total Accuracy: ', num2str(acc)]);
end
