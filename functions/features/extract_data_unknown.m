function [training_data_unknown, testing_data_unknown] = extract_data_unknown(classes, scaling_data, options)
% EXTRACT_DATA_UNKNOWN Estrae tutte le maschere dei primi 2 struct per il training,
% e tutte le maschere dell'ultimo per il test. Tutte con label 11.
%
%   INPUT:
%     - classes: struct array con .image, .masks
%     - options: struct con campi:
%         .saveFlag (default: false)
%         .standardize (default: true)
%         .log (default: false)
%
%   OUTPUT:
%     - training_data: tabella con feature da classi 1 e 2
%     - testing_data:  tabella con feature da classe 3
%     - scaling_data:  struct per standardizzazione o normalizzazione

  arguments
    classes struct
    scaling_data (2,:)
    options.saveFlag (1,1) logical = false
    options.standardize (1,1) logical = true
    options.log (1,1) logical = false
  end

  saveFlag   = options.saveFlag;
  doLog      = options.log;

  if doLog
    fprintf("Estrazione da 3 classi:\n");
    fprintf("- Training: classi 1 e 2\n");
    fprintf("- Testing: classe 3\n");
  end

  trainTables = {};
  testTables  = {};
  label = 11;  % Label fissa per tutte le maschere

  % --- Training: classi 1 e 2 ---
  for i = 1:2
    img   = classes(i).image;
    masks = classes(i).masks;

    for j = 1:numel(masks)
      if doLog
        fprintf('Training: Classe %d - Maschera %d/%d\n', i, j, numel(masks));
      end
      trainTables{end+1} = compute_descriptors(img, masks{j}, categorical(label));
    end
  end

  % --- Testing: classe 3 ---
  img   = classes(3).image;
  masks = classes(3).masks;

  for j = 1:numel(masks)
    if doLog
      fprintf('Testing: Classe 3 - Maschera %d/%d\n', j, numel(masks));
    end
    testTables{end+1} = compute_descriptors(img, masks{j}, categorical(label));
  end

  % --- Combina, normalizza e salva ---
  training_data_unknown = vertcat(trainTables{:});
  testing_data_unknown  = vertcat(testTables{:});

  if options.standardize
    training_data_unknown = standardize_features(training_data_unknown, scaling_data);
    testing_data_unknown = standardize_features(testing_data_unknown, scaling_data);
  else
    training_data_unknown = normalize_features(training_data_unknown, scaling_data);
    testing_data_unknown = normalize_features(testing_data_unknown, scaling_data);
  end

  if saveFlag
    save("data/data_unknown.mat", "training_data_unknown", "testing_data_unknown");
  end
end
