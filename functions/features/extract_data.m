function [training_data, testing_data, scaling_data, training_data_unknown, testing_data_unknown] ...
  = extract_data(class_struct, unknown_struct, options)
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
%           .SaveFlag      : (bool, default false) se true, salva i dati su file MAT
%           .standardize   : (bool, default false) se true, usa z-score invece di [0,1]
%           .log           : (bool, default false) stampa messaggi di log
%           .DoParallel   : (bool, default true) abilita la parallelizzazione su più core
%
%   OUTPUT:
%       training_data - Tabella con le feature delle maschere di training per ogni classe
%       testing_data  - Tabella con le feature delle maschere di testing per ogni classe
%       scaling_data  - Struct con min/max (o mean/std) per normalizzazione o standardizzazione
%       training_data_unknown - Tabella con le feature degli oggetti sconosciuti
%       testing_data_unknown  - Tabella con le feature degli oggetti sconosciuti
%
%   NOTE:
%       - Ogni classe deve avere un numero sufficiente di maschere in modo che, alla riga corrispondente di
%         test_indexes, gli indici di test siano compresi nel numero totale delle maschere.
%       - La parallelizzazione viene gestita internamente e può essere disabilitata.
%       - I dati vengono salvati automaticamente se SaveFlag è true.

  arguments
    class_struct struct
    unknown_struct struct
    options.SaveFlag (1,1) logical = false
    options.Scaling (1,1) string {mustBeMember(options.Scaling, ["standardize", "normalize", "none"])} = "standardize"
    options.log (1,1) logical = false
    options.DoParallel (1,1) logical = true
  end

  SaveFlag     = options.SaveFlag;
  doLog        = options.log;
  doParallel   = options.DoParallel;
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
    fprintf('SaveFlag: %d\n', SaveFlag);
    fprintf('Tipo di scaling: %s\n', options.Scaling);
    fprintf('Parallelizzazione attiva: %d\n', doParallel);
    fprintf('Numero di classi: %d\n', nClasses);
    fprintf('Controllo maschere...\n');
  end

  % Matrice di indici per i test (ogni riga corrisponde ad una classe)
  test_indexes = [1,2,5,8,10;...
                  2,3,6,8,11;...
                  1,5,8,9,11;...
                  1,4,6,14,15;...
                  4,5,8,10,12;...
                  2,5,8,9,15;...
                  2,4,5,7,11;...
                  2,4,8,9,10;...
                  2,7,8,10,11;...
                  2,3,5,6,17];

  % Controllo che ogni classe abbia sufficienti maschere.
  for iClass = 1:nClasses
    if numel(class_struct(iClass).masks) < max(test_indexes(iClass,:))
      error('La classe %d ha solo %d maschere, mentre sono richiesti almeno %d in base a test_indexes.', ...
          iClass, numel(class_struct(iClass).masks), max(test_indexes(iClass,:)));
    end
  end

  if doLog
    fprintf('Tutte le classi hanno le maschere necessarie.\n');
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

    % Definizione indici per il testing e il training
    test_idx  = test_indexes(iClass, :);
    train_idx = setdiff(1:numel(masks), test_idx);

    % --- Estrazione per Training ---
    nTrain = numel(train_idx);
    tmpTrain = cell(1, nTrain);

    if doParallel
      dq = parallel.pool.DataQueue;
      updater = createProgressBar(nTrain, sprintf('Classe %d - Training', iClass));
      afterEach(dq, @(~) updater());

      parfor j = 1:nTrain
        tmpTrain{j} = compute_descriptors(img, masks{ train_idx(j) }, label);
        send(dq, j);
      end
    else
      for j = 1:nTrain
        tmpTrain{j} = compute_descriptors(img, masks{ train_idx(j) }, label);
      end
    end

    trainTables = [trainTables, tmpTrain];

    % --- Estrazione per Testing ---
    nTest = numel(test_idx);
    tmpTest = cell(1, nTest);

    if doParallel
      dq = parallel.pool.DataQueue;
      updater = createProgressBar(nTest, sprintf('Classe %d - Testing', iClass));
      afterEach(dq, @(~) updater());

      parfor j = 1:nTest
        tmpTest{j} = compute_descriptors(img, masks{ test_idx(j) }, label);
        send(dq, j);
      end
    else
      for j = 1:nTest
        tmpTest{j} = compute_descriptors(img, masks{ test_idx(j) }, label);
      end
    end

    testTables = [testTables, tmpTest];
  end

  % Costruzione tabelle finali
  training_data = vertcat(trainTables{:});
  testing_data  = vertcat(testTables{:});

  % Normalizzazione o standardizzazione
  switch options.Scaling
    case "standardize"
      [training_data, scaling_data] = standardize_features(training_data);
      testing_data = standardize_features(testing_data, scaling_data);
    case "normalize"
      [training_data, scaling_data] = normalize_features(training_data);
      testing_data = normalize_features(testing_data, scaling_data);
    case "none"
      % Crea una tabella vuota con stesse colonne del dataset (escluse le label)
      if iscategorical(training_data{:,1})
          featNames = training_data.Properties.VariableNames(2:end);
      else
          featNames = training_data.Properties.VariableNames;
      end
      zeroRow = zeros(1, numel(featNames));
      scaling_data = array2table([zeroRow; zeroRow], 'VariableNames', featNames);
  end

  [training_data_unknown, testing_data_unknown] = extract_data_unknown(unknown_struct, scaling_data, ...
    SaveFlag=false, scaling=options.Scaling, log=doLog);

  if SaveFlag
    save('data/data.mat', 'training_data', 'testing_data', 'scaling_data', 'training_data_unknown', 'testing_data_unknown');
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
