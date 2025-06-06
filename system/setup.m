%% caricamento dati
load("data/classes_structs.mat", "classes");
load("data/unknown_structs.mat", "unknown_structs");

%% estrazione delle features
disp("avviamento pool parallel...");
parpool;

disp("data extraction in corso...");
[traning_data, testing_data, scaling_data, training_data_unknown, testing_data_unknown] = ...
    extract_data(classes, unknown_structs, log=true, scaling="standardize", SaveFlag=true, DoParallel=true);

%% allenamento classificatore
[classifier, ~, ~, ~] = train_knn_classifier(traning_data, testing_data, ...
    NumFeatRange=[22, 28], NumNeighbors=5, Optimize=false, VisualizeResults=false, SaveFlag=true);

%% allenamento detector
[detector, ~, ~] = train_detector(traning_data, testing_data, ...
    training_data_unknown, testing_data_unknown, ...
    SaveFlag=true, NumFeatRange=[18,20], VisualizeResults=false);
