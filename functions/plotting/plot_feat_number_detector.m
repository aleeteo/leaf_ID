function plot_feat_number_detector(training_data, testing_data, training_data_unknown, testing_data_unknown)
% valuta l'accuracy rispetto al numero di feature selezionate
% per il training del riconoscitore di foglie
arguments
    training_data table
    testing_data table
    training_data_unknown table
    testing_data_unknown table
end

  nFeatures = size(training_data, 2) - 1; % Assuming one column is Label
  accuracies = zeros(nFeatures, 1);

  for i = 1:nFeatures
    [~, acc, ~] = train_detector(training_data, testing_data, ...
                                    training_data_unknown, testing_data_unknown, ...
                                    NumFeatRange=[i, i]);
    accuracies(i) = acc;
  end

  % Plot accuracies
  figure;
  % bar(accuracies);
  plot(accuracies, 'o-');

  ylabel('Accuracy');
  xlabel('Number of Features');
  title('Accuracy riconoscitore foglie in base al numero di feature');
  grid on;
end
