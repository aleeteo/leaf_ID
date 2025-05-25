function plot_feat_number_accuracy(training_data, testing_data, opts)
% Valuta diversi classificatori e visualizza le accuracy
arguments
    training_data
    testing_data
    opts.optimize = false
    opts.SaveFlag = false
end

  nFeatures = size(training_data, 2) - 1; % Assuming one column is Label
  accuracies = zeros(nFeatures, 1);

  for i = 1:nFeatures
    [~, acc, ~, ~] = train_knn_classifier(training_data, testing_data, NumFeatRange=[i, i], ...
                                          NumNeighbors=3, Optimize=opts.optimize, ...
                                          VisualizeResults=false, SaveFlag=opts.SaveFlag);
    accuracies(i) = acc;
  end


  % Plot accuracies
  figure;
  % bar(accuracies);
  plot(accuracies, 'o-');

  ylabel('Accuracy');
  xlabel('Number of Features');
  title('Accuracy knn in base al numero di feature');
  grid on;
end
