function totAccuracy = test_classify_multiple_cl(C, minmax, visualize)
  arguments
    C 
    % minmax (:, 2) table = []
    minmax table = table();
    visualize logical = false
  end

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

  totAccuracy = 0;

  for i = 1:numel(images)
    img = imread(images{i});
    mask = imread(masks{i});
    label = load(labels{i}).labeledImage;
    
    if size(minmax, 1) == 0
      pred = classify_multiple_cl(img, mask, C);
    else
      pred = classify_multiple_cl(img, mask, C, minmax);
    end

    if visualize
      confmat = confusionmat(label(:), pred(:));
      figure;
      subplot(1,2,1), imagesc(pred);
      subplot(1,2,2), confusionchart(abs(confmat), 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized'), title('Confusion Matrix');
    end

    correct = sum((label(:) == pred(:)) & (pred(:) ~= 0));
    total = nnz(pred(:) ~= 0);
    accuracy = correct / total;
    totAccuracy = totAccuracy + accuracy;
    disp(['Accuracy: ', num2str(accuracy)]);
  end

  totAccuracy = totAccuracy / numel(images);
  disp(['Total Accuracy: ', num2str(totAccuracy)]);
end
