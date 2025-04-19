function [training_data, testing_data, minmax] = extract_data(class_struct, saveFlag)
  % EXTRACT_DATA Estrae e normalizza le feature da un dataset strutturato.
  %
  %   [training_data, testing_data, minmax] = extract_data(class_struct, saveFlag)
  %
  %   INPUT:
  %       class_struct - Struct array con i campi:
  %           .image : immagine RGB
  %           .masks : cell array di maschere binarie
  %           .label : etichetta della classe
  %
  %       saveFlag - Booleano (default false). Se true, salva i dati su file MAT.
  %
  %   OUTPUT:
  %       training_data - Tabella con le feature delle prime 10 maschere/class
  %       testing_data  - Tabella con le feature delle restanti maschere/class
  %       minmax        - Struct con min/max per la normalizzazione
  %
  %   NOTE:
  %       - Verifica che ogni classe abbia almeno 10 maschere.
  %       - Randomizza l’ordine delle maschere per ridurre overfitting.
  %       - Normalizza le feature su base [0, 1] rispetto al training set.
  %       - Supporta il salvataggio automatico su 'data/data.mat'.
 
  arguments
    class_struct struct
    saveFlag {mustBeNumericOrLogical} = false
  end

  nClasses = numel(class_struct);

  % Controllo maschere
  for iClass = 1:nClasses
      if numel(class_struct(iClass).masks) < 10
          error('La classe %d ha solo %d maschere, ne servono almeno 10.', ...
                iClass, numel(class_struct(iClass).masks));
      end
  end

  % Accumulatori
  trainTables = {};
  testTables  = {};

  for iClass = 1:nClasses
      img    = class_struct(iClass).image;
      masks  = class_struct(iClass).masks;
      label  = class_struct(iClass).label;

      idx = randperm(numel(masks));  % Randomizzazione

      % Training: prime 10
      for j = 1:10
          desc = compute_descriptors(img, masks{idx(j)}, label);
          trainTables{end+1} = desc;
      end

      % Testing: resto
      for j = 11:numel(masks)
          desc = compute_descriptors(img, masks{idx(j)}, label);
          testTables{end+1} = desc;
      end
  end

  % Costruzione finali
  training_data = vertcat(trainTables{:});
  testing_data  = vertcat(testTables{:});

  % Normalizzazione
  [training_data, minmax] = normalize_features(training_data);
  [testing_data, ~]       = normalize_features(testing_data, minmax);

  % Salvataggio
  if saveFlag
      save('data/data.mat', 'training_data', 'testing_data', 'minmax');
  end
end
