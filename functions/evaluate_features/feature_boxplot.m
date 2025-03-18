function feature_boxplot(data, features_names, feature_index)
    % Funzione per visualizzare il boxplot di una specifica feature rispetto alle classi
    % Supporta input come cell array o matrice numerica
    %
    % Parametri:
    %   features: cell array o matrice in cui la prima colonna rappresenta le classi
    %             e le altre colonne rappresentano le feature
    %   feature_index: indice della feature da visualizzare (escludendo la colonna delle classi)
    
    % Controllo che l'indice sia valido
    if feature_index < 1 || feature_index > size(data, 2) - 1
        error('Indice della feature non valido. Deve essere tra 1 e %d.', size(data, 2) - 1);
    end
    
    % Estrarre le classi e la feature selezionata
    classi = data(:,1); % La prima colonna contiene le classi
    feature_data = data(:, feature_index + 1); % +1 per compensare la colonna delle classi
    
    % Creazione del boxplot
    figure;
    boxplot(feature_data, classi);
    title(['Boxplot della Feature ', num2str(feature_index)]);
    xlabel('Classe');
    ylabel(['Feature ', features_names{feature_index}]);
end
