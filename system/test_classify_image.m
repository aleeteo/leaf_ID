function results = test_classify_image(classifier, detector, scaling_data, options)
  arguments
    classifier
    detector
    scaling_data
    options.directory (1,:) string = "dataset/03_classes"
    options.standardize (1,1) logical = true
    options.DoParallel (1,1) logical = true
    options.visualize_predictions (1,1) logical = false
    options.visualize_confmat (1,1) logical = false
  end
  
  directory = options.directory;
  images = getFilePaths(char(directory + "/images"));
  labels = getFilePaths(char(directory + "/labels"));

  numImgs = numel(images);
  pixelAccuracies    = zeros(numImgs, 1);
  instanceAccuracies = zeros(numImgs, 1);
  numObjects         = zeros(numImgs, 1);
  correctClass       = zeros(numImgs, 1);
  wrongClass         = zeros(numImgs, 1);

  for i = 1:numImgs
    img = imread(images{i});
    mask = segmentation5(img);
    label = load(labels{i}).labeledImage;

    [pred, instanceAccuracy, cm] = classify_multiple(img, mask, classifier, detector, scaling_data, ...
                      labels=label, ...
                      standardize=options.standardize, ...
                      DoParallel=options.DoParallel);

    % Accuracy pixel-wise
    correct = sum((label(:) == pred(:)) & (pred(:) ~= 0));
    total = nnz(pred(:) ~= 0);
    pixelAccuracy = correct / total;

    % Salva metriche
    pixelAccuracies(i)    = pixelAccuracy;
    instanceAccuracies(i) = instanceAccuracy;

    % Estrazione CM
    if ~isempty(cm)
      numObjects(i)   = sum(cm(:));
      correctClass(i) = sum(diag(cm));
      wrongClass(i)   = numObjects(i) - correctClass(i);
    else
      numObjects(i) = 0;
      correctClass(i) = 0;
      wrongClass(i) = 0;
    end

    % Visualizzazioni opzionali
    if options.visualize_predictions
      figure;
      subplot(1,2,1), imagesc(pred), axis image off, title('Predizione');
      subplot(1,2,2), imagesc(label), axis image off, title('Label vera');
    end

    if options.visualize_confmat
      figure;
      confusionchart(cm, 'RowSummary', 'row-normalized', ...
                          'ColumnSummary', 'column-normalized');
      title('Confusion Matrix');
    end
  end

  % Tabella risultati
  imageNames = string(images);
  results = table(imageNames, pixelAccuracies, instanceAccuracies, ...
                  numObjects, correctClass, wrongClass, ...
                  'VariableNames', {'Image', 'PixelAccuracy', 'InstanceAccuracy', ...
                                    'NumObjects', 'Correct', 'Incorrect'});

  fprintf("\n ------------------------------\n");
  disp(results)

  % Medie finali
  meanPixelAccuracy = mean(pixelAccuracies);
  meanInstanceAccuracy = mean(instanceAccuracies);
  fprintf('\n📊 Accuracy media su %d immagini:\n', numImgs);
  fprintf(' - Pixel Accuracy media   : %.4f\n', meanPixelAccuracy);
  fprintf(' - Instance Accuracy media: %.4f\n', meanInstanceAccuracy);
end
