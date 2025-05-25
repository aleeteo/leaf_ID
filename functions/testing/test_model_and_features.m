function [classifier, detector, scaling_data] = test_model_and_features(varargin)
  % input handling
  % if nargin < 2
  %   error('Not enough input arguments. Provide training and testing data.');
  % end
  p = inputParser;
  addParameter(p, 'SaveFlag', false, @(x) islogical(x));
  addParameter(p, 'feature_number', 0, @(x) isnumeric(x) && isscalar(x));
  parse(p, varargin{:});
  SaveFlag = p.Results.SaveFlag;
  feature_number = p.Results.feature_number;

  load("data/classes_structs.mat", "classes");
  disp("extracting data...");
  [training_data, testing_data, scaling_data] = extract_data(classes);
  disp("data extracted");
  disp(cell2mat(training_data.Properties.VariableNames));

  % training and testing on test set
  disp("training classifier")
  [classifier, test_accuracy] = test_svm(training_data, testing_data, feature_number, SaveFlag);
  misc_accuracy = test_accuracy;
  unknown_accuracy = test_accuracy;
  detector = test_svm_detector(training_data, testing_data, feature_number, false);

  disp(["accuracy on test set: " num2str(test_accuracy)]);
  disp(["accuracy on misc set: " num2str(misc_accuracy)]);
  disp(["accuracy on unknown set: " num2str(unknown_accuracy)]);
end
