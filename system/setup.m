%% caricamento dati
fprintf("caricamento struct relative alle classi...\n\n");
load("data/classes_structs.mat", "classes");
load("data/unknown_structs.mat", "unknown_structs");

%% estrazione delle features
fprintf("inizializzazione del pool di processi...\n");
parpool;

fprintf("estrazione features...\n");
[traning_data, testing_data, scaling_data, training_data_unknown, testing_data_unknown] = ...
    extract_data(classes, unknown_structs, log=true, scaling="standardize", SaveFlag=true, DoParallel=true);
fprintf("features estratte.\n\n");

%% allenamento classificatore
fprintf("allenamento classificatore...\n");
[classifier, ~, ~, ~] = train_knn_classifier(traning_data, testing_data, ...
    NumFeatRange=[22, 28], NumNeighbors=5, Optimize=false, VisualizeResults=false, SaveFlag=true);
fprintf("classificatore allenato.\n\n");


%% allenamento detector
fprintf("allenamento detector...\n");
[detector, ~, ~] = train_detector(traning_data, testing_data, ...
    training_data_unknown, testing_data_unknown, ...
    SaveFlag=true, NumFeatRange=[18,20], VisualizeResults=false);
fprintf("detector allenato.\n\n");
