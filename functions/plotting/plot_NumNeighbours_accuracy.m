function plot_NumNeighbours_accuracy(training_data, testing_data)
% Valuta diverse quantita' per i neighbours di knn
% e visualizza le accuracy

arguments
    training_data
    testing_data
end

  num_neighbors = 1:2:27;  % Vettore dei numeri di vicini da testare
  accuracies = zeros(size(num_neighbors));  % Preallocazione coerente

  for idx = 1:length(num_neighbors)
    k = num_neighbors(idx);  % Numero attuale di vicini
    [~, acc, ~, ~] = train_knn_classifier(training_data, testing_data, ...
                                          NumFeatRange=[22,28], ...
                                          NumNeighbors=k, ...
                                          VisualizeResults=false);
    accuracies(idx) = acc;
  end

  % Plot accuracies
  figure;
  plot(num_neighbors, accuracies, 'o-', 'LineWidth', 2, 'MarkerSize', 6);
  xlabel('Number of Neighbors (k)');
  ylabel('Accuracy');
  title('Accuracy vs. Number of Neighbors for k-NN');
  grid on;
end
