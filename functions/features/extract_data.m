function [training_data, testing_data, minmax] = extract_data(class_struct, saveFlag)
  arguments
    class_struct struct
    saveFlag {mustBeNumericOrLogical} = false
  end

  %% Controllo che ogni classe abbia almeno 10 maschere
  nClasses = numel(class_struct);
  for iClass = 1:nClasses
      nMasks = numel(class_struct(iClass).masks);
      if nMasks < 10
          error('La classe %d ha solo %d maschere, ne servono almeno 10.', iClass, nMasks);
      end
  end

  %% Calcola il numero di righe totali per training e testing
  totalTrainRows = nClasses * 10; % 10 maschere per classe (fisse)
  totalTestRows  = 0;
  for iClass = 1:nClasses
      totalTestRows = totalTestRows + (numel(class_struct(iClass).masks) - 10);
  end

  %% Ottengo i nomi delle feature dalla prima maschera
  img  = class_struct(1).image;
  mask = class_struct(1).masks{1};
  [~, feature_names] = compute_descriptors(img, mask, class_struct(1).label);

  %% Costruisco le tabelle in cui salvare training e testing
  feature_types = [{'categorical'}, repmat({'double'}, 1, numel(feature_names) - 1)];

  training_data = table('Size', [totalTrainRows, numel(feature_names)], ...
      'VariableTypes', feature_types, ...
      'VariableNames', feature_names);

  testing_data = table('Size', [totalTestRows, numel(feature_names)], ...
      'VariableTypes', feature_types, ...
      'VariableNames', feature_names);

  %% Riempio training_data e testing_data
  trainIdx = 1;
  testIdx  = 1;

  for iClass = 1:nClasses
      img    = class_struct(iClass).image;
      nMasks = numel(class_struct(iClass).masks);

      % Prime 10 maschere -> training
      for j = 1:10
          descriptors = compute_descriptors(img, class_struct(iClass).masks{j}, class_struct(iClass).label);
          training_data(trainIdx, :) = descriptors;
          trainIdx = trainIdx + 1;
      end

      % Dall'11-esima in poi -> testing
      for j = 11:nMasks
          descriptors = compute_descriptors(img, class_struct(iClass).masks{j}, class_struct(iClass).label);
          testing_data(testIdx, :) = descriptors;
          testIdx = testIdx + 1;
      end
  end

  %% Normalizzazione delle feature
  [training_data, minmax] = normalize_features(training_data);
  [testing_data, ~]       = normalize_features(testing_data, minmax);

  %% Salvataggio su file
  if saveFlag
      save('data/data.mat', 'training_data', 'testing_data', 'minmax');
  end
end
