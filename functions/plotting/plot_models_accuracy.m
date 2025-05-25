function plot_models_accuracy(training_data, testing_data, opts)
% Valuta diversi classificatori e visualizza le accuracy
arguments
    training_data
    testing_data
    opts.optimize = false
    opts.SaveFlag = false
end

  models = ["tree", "svm", "knn", "bayes", "ensamble"];
  accuracies = zeros(size(models));

  for i = 1:length(models)
    model = models(i);
    fprintf('Testing model: %s\n', model);
    try
      [~, acc] = test_classification(training_data, testing_data, ...
        "model", model, "optimize", opts.optimize, "SaveFlag", opts.SaveFlag);
      accuracies(i) = acc;
    catch ME
      warning("Errore nel modello %s: %s", model, ME.message);
      accuracies(i) = NaN;
    end
  end

  % Plot accuracies
  figure;
  bar(accuracies);
  set(gca, 'XTickLabel', models, 'XTick', 1:length(models));
  ylabel('Accuracy');
  title('Accuracy dei diversi modelli di classificazione');
  grid on;
end
