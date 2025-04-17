function f1_macro_obj = test_classify_multiple_new(C, minmax, images, masks, labels)
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

  % STEP 1: Conta gli oggetti totali
  total_objects = 0;
  for i = 1:numel(images)
      mask = imread(masks{i});
      [~, num_labels] = bwlabel(mask);
      total_objects = total_objects + num_labels;
  end

  % STEP 2: Prealloca vettori numerici
  all_true_labels = zeros(total_objects, 1);
  all_predicted_labels = zeros(total_objects, 1);

  % STEP 3: Riempili con le classi reali/predette
  current_index = 1;
  for i = 1:numel(images)
      img = imread(images{i});
      mask = imread(masks{i});
      loaded = load(labels{i});
      label_img = loaded.labeledImage;

      pred = classify_multiple(img, mask, C, minmax);
      [comps, num_labels] = bwlabel(mask);

      for objIdx = 1:num_labels
          item_mask = (comps == objIdx);

          predicted_object_label = mode(pred(item_mask));
          true_object_label      = mode(label_img(item_mask));

          all_predicted_labels(current_index) = predicted_object_label;
          all_true_labels(current_index)      = true_object_label;

          current_index = current_index + 1;
      end
  end

  % Converto in categorical
  true_cats = categorical(all_true_labels);
  pred_cats = categorical(all_predicted_labels);

  % Calcolo dell’accuratezza (oggetto-based)
  acc_obj = mean(true_cats == pred_cats);

  % Calcolo dell'F1 macro
  f1_macro_obj = compute_f1_score(true_cats, pred_cats);

  % Stampa risultati
  disp(['Accuracy (oggetto-based): ', num2str(acc_obj)]);
  disp(['F1 macro (oggetto-based): ', num2str(f1_macro_obj)]);
end
