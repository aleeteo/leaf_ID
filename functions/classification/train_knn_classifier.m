function [classifier, test_accuracy, cm, f1_score] = train_knn_classifier(training_data, testing_data, options)
  arguments
    training_data table
    testing_data table
    options.NumFeatRange (1,2) double {mustBeNonnegative} = [10, inf]
    options.NumNeighbors (1,1) double {mustBePositive} = 3
    options.Optimize (1,1) {mustBeNumericOrLogical} = false
    options.VisualizeResults (1,1) logical = false
    options.SaveFlag (1,1) logical = false
  end

  if options.Optimize 
    optimize='auto'; 
  else 
    optimize='none'; 
  end

  bestIdx = select_best_features(training_data, "Label", ...
                   'NumFeatRange', options.NumFeatRange, ...
                   'Importanza', 'mrmrRank', ...
                   'Classifier', @(X, Y) fitcknn(X, Y, 'NumNeighbors', options.NumNeighbors));
  training_data = training_data(:, [1 bestIdx]);
  testing_data = testing_data(:, [1 bestIdx]);

  classifier = fitcknn(training_data, 'Label', ...
                      'NumNeighbors', options.NumNeighbors, ...
                      'OptimizeHyperparameters', optimize); 

  pred = predict(classifier, testing_data);

  cm = confusionmat(testing_data.Label, pred);
  test_accuracy = sum(diag(cm)) / sum(cm(:));
  f1_score = compute_f1_score(testing_data.Label, pred);

  if options.VisualizeResults
    figure;
    heatmap(cm, 'ColorbarVisible', 'on', ...
            'XLabel', 'Predicted Class', ...
            'YLabel', 'True Class', ...
            'Title', 'Confusion Matrix');
    title('Confusion Matrix');
    fprintf('F1 Score: %f\n', f1_score);
    figure;
    confusionchart(abs(cm));
  end

  if options.SaveFlag
    % Save the model to a file
    modelFileName = 'data/classifier.mat';
    save(modelFileName, 'classifier', 'test_accuracy');
    fprintf('Model saved to %s\n', modelFileName);
  end
end
