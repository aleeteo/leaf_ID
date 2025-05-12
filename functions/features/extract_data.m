function [training_data, testing_data, scaling_data] = extract_data(class_struct, options)
% EXTRACT_DATA Estrae e normalizza le feature da un dataset strutturato.
%
%   [training_data, testing_data, scaling_data] = extract_data(class_struct, options)
%
%   INPUT:
%       class_struct - Struct array con i campi:
%           .image : immagine RGB
%           .masks : cell array di maschere binarie
%           .label : etichetta della classe
%
%       options - Struttura con campi:
%           .saveFlag      : (bool, default false) se true, salva i dati su file MAT
%           .standardize   : (bool, default false) se true, usa z-score invece di [0,1]
%           .log           : (bool, default false) stampa messaggi di log
%           .parallelize   : (bool, default true) abilita la parallelizzazione su più core
%
%   OUTPUT:
%       training_data - Tabella con le feature delle prime 10 maschere/class
%       testing_data  - Tabella con le feature delle restanti maschere/class
%       scaling_data  - Struct con min/max (o mean/std) per normalizzazione o standardizzazione
%       training_data_unknown - Tabella con le feature e maschere sconosciute
%
%   NOTE:
%       - Ogni classe deve avere almeno 10 maschere.
%       - Le maschere vengono randomizzate per ridurre l’overfitting.
%       - La parallelizzazione viene gestita internamente e può essere disabilitata.
%       - I dati vengono salvati automaticamente se saveFlag è true.

  arguments
    class_struct struct
    options.saveFlag (1,1) logical = false
    options.standardize (1,1) logical = true
    options.log (1,1) logical = false
    options.parallelize (1,1) logical = true
  end

  saveFlag     = options.saveFlag;
  doLog        = options.log;
  doParallel   = options.parallelize;
  nClasses     = numel(class_struct);

  % Avvio automatico del pool se serve
  if doParallel && isempty(gcp('nocreate'))
    if doLog
      fprintf('Nessun pool attivo. Avvio automatico...\n');
    end
    parpool;
  end

  if doLog
    fprintf('Log attivato.\n');
    fprintf('saveFlag: %d\n', saveFlag);
    fprintf('Standardizzazione con z-score: %d\n', options.standardize);
    fprintf('Parallelizzazione attiva: %d\n', doParallel);
    fprintf('Numero di classi: %d\n', nClasses);
    fprintf('Controllo maschere...\n');
  end

  % Controllo maschere
  for iClass = 1:nClasses
    if numel(class_struct(iClass).masks) < 10
      error('La classe %d ha solo %d maschere, ne servono almeno 10.', ...
          iClass, numel(class_struct(iClass).masks));
    end
  end

  if doLog
    fprintf('Tutte le classi hanno almeno 10 maschere.\n');
    fprintf('Inizio estrazione feature...\n');
  end

  trainTables = {};
  testTables  = {};

  for iClass = 1:nClasses
    if doLog
      fprintf('Classe %d/%d\n', iClass, nClasses);
    end

    img    = class_struct(iClass).image;
    masks  = class_struct(iClass).masks;
    label  = class_struct(iClass).label;

    idx = randperm(numel(masks));  % Randomizzazione

    % --- Training ---
    nTrain = 10;
    tmpTrain = cell(1, nTrain);

    if doParallel
      dq = parallel.pool.DataQueue;
      updater = createProgressBar(nTrain, sprintf('Classe %d - Training', iClass));
      afterEach(dq, @(~) updater());

      parfor j = 1:nTrain
        tmpTrain{j} = compute_descriptors(img, masks{idx(j)}, label);
        send(dq, j);
      end
    else
      for j = 1:nTrain
        tmpTrain{j} = compute_descriptors(img, masks{idx(j)}, label);
      end
    end

    trainTables = [trainTables, tmpTrain];

    % --- Testing ---
    nTest = numel(masks) - nTrain;
    if nTest > 0
      tmpTest = cell(1, nTest);

      if doParallel
        dq = parallel.pool.DataQueue;
        updater = createProgressBar(nTest, sprintf('Classe %d - Testing', iClass));
        afterEach(dq, @(~) updater());

        parfor j = 1:nTest
          tmpTest{j} = compute_descriptors(img, masks{idx(j + nTrain)}, label);
          send(dq, j);
        end
      else
        for j = 1:nTest
          tmpTest{j} = compute_descriptors(img, masks{idx(j + nTrain)}, label);
        end
      end

      testTables = [testTables, tmpTest];
    end
  end

  % Costruzione tabelle finali
  training_data = vertcat(trainTables{:});
  testing_data  = vertcat(testTables{:});

  % Normalizzazione o standardizzazione
  if options.standardize
    [training_data, scaling_data] = standardize_features(training_data);
    testing_data = standardize_features(testing_data, scaling_data);
  else
    [training_data, scaling_data] = normalize_features(training_data);
    testing_data = normalize_features(testing_data, scaling_data);
  end

  if saveFlag
    save('data/data.mat', 'training_data', 'testing_data', 'scaling_data');
  end
end

% ========================
% Funzione progress bar
% ========================
function updater = createProgressBar(nTotal, title)
  n = 0;
  h = waitbar(0, title);
  updater = @update;

  function update()
    n = n + 1;
    waitbar(n / nTotal, h);
    if n == nTotal
      close(h);
    end
  end
end
