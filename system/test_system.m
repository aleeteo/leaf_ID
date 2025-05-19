%% setting script variables
load_data = true;
load_bestIdx = false;
load_classifier = true;
load_detector = true;
classifier_model_type = "knn"; %"svm", "tree", "knn", "bayes", "ensamble", "auto"
optimize_classifier = false;

%% data loading/extraction
if load_data
  fprintf("loading data...\n");
  load("data/data.mat", "training_data", "testing_data", "scaling_data", "training_data_unknown", "testing_data_unknown");
else
  fprintf("loading classes_structs...\n");
  load("data/classes_structs.mat", "classes");
  load("data/unknown_structs.mat", "unknown_structs");
  fprintf("extracting data...\n");
  [training_data, testing_data, scaling_data] = extract_data(classes, unknown_structs, log=true, standardize=true, saveFlag=false, parallelize=true);
end

%% feature selection
if load_bestIdx
  fprintf("loading bestIdx...\n");
  bestIdx = load("data/selected_features.mat", "bestSet").bestSet;
else
  fprintf("selecting features...\n");
  bestIdx = select_best_features(training_data, "Label", Verbose=true, NumFeatRange=[23, 27]);
end

sub_training_data = training_data(:, [1 bestIdx]);
sub_testing_data = testing_data(:, [1 bestIdx]);

%% classifier
if load_classifier
  fprintf("loading classifier...\n");
  load("data/classifier.mat", "classifier", "test_accuracy");
else
  fprintf("training classifier...\n");
  [classifier, test_accuracy] = test_classification(sub_training_data, sub_testing_data, ...
                                   saveFlag=false, ...
                                   model=classifier_model_type, ...
                                   optimize=optimize_classifier);
end
fprintf("classifier accuracy on test_set: %.2f%%\n", test_accuracy * 100);

%% detector 
if load_detector
  fprintf("loading detector...\n");
  load("data/detector.mat", "detector", "test_accuracy");
else
  fprintf("training leaf detector...\n");
  [detector, test_accuracy] = test_svm_detector(sub_training_data, sub_testing_data, feature_number=0, saveFlag=false);
end
fprintf("detector accuracy on test_set: %.2f%%\n", test_accuracy * 100);

%% testing on more images
fprintf("testing on training and test set (instance based)\n")
test_classify_multiple(classifier, detector, scaling_data, ...
                       directory="dataset/03_classes", ...
                       standardize=true, parallelize=true, ...
                       visualize_predictions=false, ...
                       visualize_confmat=false);

fprintf("testing on misc set\n")
test_classify_multiple(classifier, detector, scaling_data, ...
                       directory="dataset/05_miscs", ...
                       standardize=true, parallelize=true, ...
                       visualize_predictions=false, ...
                       visualize_confmat=false);

fprintf("testing on unknowns set (instance based)\n")
test_classify_multiple(classifier, detector, scaling_data, ...
                       directory="dataset/06_unknown_miscs", ...
                       standardize=true, parallelize=true, ...
                       visualize_predictions=false, ...
                       visualize_confmat=false);
