% Caricamento dei dati
% Assumiamo che 'data' sia una matrice numerica dove:
% - La prima colonna contiene le etichette (classi)
% - Le altre colonne contengono le feature numeriche

% Assumiamo che 'feature_names' sia un array cell monodimensionale contenente i nomi delle feature,
% con il primo elemento che è 'labels'

% Separazione delle etichette e delle feature
labels = data(:, 1);         % Estrai le etichette (prima colonna)
features = data(:, 2:end);   % Estrai le feature (restanti colonne)

% Creazione di una tabella con nomi delle feature
feature_names = feature_names(2:end); % Rimuove il primo elemento ('labels')
dataTable = array2table(features, 'VariableNames', feature_names);

% Aggiunta delle etichette come colonna categoriale
dataTable.Labels = categorical(labels);

% Avvio del Classification Learner
classificationLearner
