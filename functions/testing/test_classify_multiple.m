function acc = test_classify_multiple(classifier, recognizer, scaling_data, varargin)
%TEST_CLASSIFY_MULTIPLE Classifica oggetti in più immagini usando classificatore e riconoscitore.

  % Parser per parametri opzionali
  p = inputParser;
  addParameter(p, 'Visualize', false, @(x) islogical(x));
  addParameter(p, 'Images', {}, @(x) iscell(x));
  addParameter(p, 'Masks', {}, @(x) iscell(x));
  addParameter(p, 'Labels', {}, @(x) iscell(x));
  parse(p, varargin{:});

  images = p.Results.Images;
  masks = p.Results.Masks;
  labels = p.Results.Labels;
  visualize = p.Results.Visualize;

  % Caricamento liste da file se non fornite
  if isempty(images)
    images = textscan(fopen('dataset/03_classes/images.list'), '%s'); fclose('all'); images = images{1};
    masks  = textscan(fopen('dataset/03_classes/masks.list'), '%s');  fclose('all'); masks  = masks{1};
    labels = textscan(fopen('dataset/03_classes/labels.list'), '%s'); fclose('all'); labels = labels{1};
  end

  acc = 0;
  for i = 1:numel(images)
    img = imread(images{i});
    mask = imread(masks{i});
    label = load(labels{i}).labeledImage;

    pred = classify_multiple(img, mask, classifier, recognizer, scaling_data);

    confmat = confusionmat(label(:), pred(:));
    if visualize
      figure;
      subplot(1,2,1), imagesc(pred), axis image off, title('Predizione');
      subplot(1,2,2), imagesc(label), axis image off, title('Label vera');
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
