function [detector, accuracy, cm] = ...
  train_detector(training_data, testing_data, training_data_unknown, testing_data_unknown, options)

  arguments 
    training_data table
    testing_data table
    training_data_unknown table
    testing_data_unknown table
    % options.OutlierFraction {mustBeNumeric, mustBePositive} = 0.05
    options.saveFlag logical = false
  end

  training_data = [training_data; training_data_unknown];
  testing_data = [testing_data; testing_data_unknown];
  
  X = training_data(:, 2:end);
  Y = double(training_data.Label) <= 10;
  x_test = testing_data(:, 2:end);
  y_test = double(testing_data.Label) <= 10;

  detector = fitcensemble(X, Y, 'Method', 'Bag');  % o qualsiasi altro modello binario

  y_pred = predict(detector, x_test);

  accuracy = mean(y_pred == y_test);
  cm = confusionmat(y_test, y_pred);

  if options.saveFlag
    save('data/detector.mat', 'detector');
    fprintf('Modello salvato in data/detector.mat\n');
  end
end
