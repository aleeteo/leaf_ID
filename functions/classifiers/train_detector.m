function [detector, test_accuracy, cm] = train_detector( ...
    training_data, testing_data, training_data_unknown, testing_data_unknown, options)

  arguments 
    training_data table
    testing_data table
    training_data_unknown table
    testing_data_unknown table
    options.saveFlag logical = false
    options.NumFeatRange (1,2) double {mustBeNonnegative} = [10, inf]
  end

  % Unione dei dati noti e unknown
  training_data = [training_data; training_data_unknown];
  testing_data  = [testing_data;  testing_data_unknown];

  % Conversione delle label in booleano: true = foglia (<=10), false = unknown
  training_data.Label = double(training_data.Label) <= 10;
  testing_data.Label  = double(testing_data.Label)  <= 10;
  class(training_data.Label(1))

  % Selezione delle feature migliori
  bestSet = select_best_features(training_data, 'Label', ...
                                 NumFeatRange = options.NumFeatRange);
  fprintf('Sono state selezionate %d feature\n', length(bestSet));

  % Riduzione dei dati alle sole feature selezionate
  training_data = training_data(:, [1, bestSet]);
  testing_data  = testing_data(:, [1, bestSet]);

  % Separazione feature e target
  X = training_data(:, 2:end);
  Y = training_data.Label;
  x_test = testing_data(:, 2:end);
  y_test = testing_data.Label;

  % Addestramento del modello binario
  detector = fitcensemble(X, Y, 'Method', 'Bag');

  % Predizione e valutazione
  y_pred = (predict(detector, x_test));
  y_test = (y_test);

  test_accuracy = mean(y_pred == y_test);
  cm = confusionmat(y_test, y_pred);

  % Salvataggio opzionale
  if options.saveFlag
    save('data/detector.mat', 'detector', 'test_accuracy');
    fprintf('Modello salvato in data/detector.mat\n');
  end
end

