function [training_data, testing_data, scaling_data] = extract_data(class_struct, options)
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
    options.saveFlag (1,1) logical = false
    options.standardize logical = false
    options.log (1,1) logical = false
  end

  saveFlag = options.saveFlag;
  doLog      = options.log;

  nClasses = numel(class_struct);

  % Logging
  if doLog
    fprintf('Log attivato.\n');
    fprintf('saveFlag: %d\n', saveFlag);
    fprintf('Standardizzazione con z-score: %d\n', options.standardize);
    fprintf('Numero di classi: %d\n', nClasses);
    fprintf('Controllo maschere...\n')
  end

  % Controllo maschere
  for iClass = 1:nClasses
    if numel(class_struct(iClass).masks) < 10
      error('La classe %d ha solo %d maschere, ne servono almeno 10.', ...
          iClass, numel(class_struct(iClass).masks));
    end
  end

  % Logging
  if doLog
    fprintf('Tutte le classi hanno almeno 10 maschere.\n');
    fprintf('Inizio estrazione feature...\n');
  end

  % Accumulatori
  trainTables = {};
  testTables  = {};

  for iClass = 1:nClasses
    % Logging
    if doLog
        fprintf('Classe %d/%d\n', iClass, nClasses);
    end

    % Estrazione
    img    = class_struct(iClass).image;
    masks  = class_struct(iClass).masks;
    label  = class_struct(iClass).label;

    idx = randperm(numel(masks));  % Randomizzazione

    % Training: prime 10
    for j = 1:10
      desc = compute_descriptors(img, masks{idx(j)}, label);
      trainTables{end+1} = desc;

      % Logging
      if doLog
          fprintf('  Maschera %d/%d: %s\n', j, numel(masks), desc.Label);
      end
    end

    % Testing: resto
    for j = 11:numel(masks)
      desc = compute_descriptors(img, masks{idx(j)}, label);
      testTables{end+1} = desc;

      % Logging
      if doLog
          fprintf('  Maschera %d/%d: %s\n', j, numel(masks), desc.Label);
      end
    end
  end

  % Costruzione finali
  training_data = vertcat(trainTables{:});
  testing_data  = vertcat(testTables{:});

  if options.standardize
    % Standardizzazione
    [training_data, scaling_data] = standardize_features(training_data);
    testing_data = standardize_features(testing_data, scaling_data);
  else
    % Normalizzazione
    [training_data, scaling_data] = normalize_features(training_data);
    testing_data = normalize_features(testing_data, scaling_data);
  end


  % Salvataggio
  if saveFlag
      save('data/data.mat', 'training_data', 'testing_data', 'scaling_data');
  end
end
