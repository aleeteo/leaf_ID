function acc = test_classify_multiple(classifier, recognizer, scaling_data, options)
%TEST_CLASSIFY_MULTIPLE Classifica oggetti in più immagini usando classificatore e riconoscitore.
  arguments
    classifier
    recognizer
    scaling_data
    options.directory (1,:) string = "dataset/03_classes"
    options.standardize (1,1) logical = true
    options.parallelize (1,1) logical = true
    options.visualize_predictions (1,1) logical = false
    options.visualize_confmat (1,1) logical = false
  end

  directory = options.directory;
  images = getFilePaths(char(directory + "/images"));
  masks = getFilePaths(char(directory + "/masks"));
  labels = getFilePaths(char(directory + "/labels"));

  acc = 0;
  for i = 1:numel(images)
    img = imread(images{i});
    mask = imread(masks{i});
    label = load(labels{i}).labeledImage;

    pred = classify_multiple(img, mask, classifier, recognizer, scaling_data, standardize=true, parallelize=options.parallelize);

    confmat = confusionmat(label(:), pred(:));
    if options.visualize_predictions
      figure;
      subplot(1,2,1), imagesc(pred), axis image off, title('Predizione');
      subplot(1,2,2), imagesc(label), axis image off, title('Label vera');
    end
    if options.visualize_confmat
      figure;
      confusionchart(abs(confmat), ...
          'RowSummary', 'row-normalized', ...
          'ColumnSummary', 'column-normalized'), title('Confusion Matrix');
    end

    correct = sum((label(:) == pred(:)) & (pred(:) ~= 0));
    total = nnz(pred(:) ~= 0);
    accuracy = correct / total;
    acc = acc + accuracy;
    disp(['Accuracy immagine ', num2str(i), ': ', num2str(accuracy)]);
  end

  acc = acc / numel(images);
  disp(['Accuracy media: ', num2str(acc)]);
end
