function features_scatter(data, feature_i, feature_j)
    % Funzione per generare uno scatterplot tra due feature
    % colorando i punti in base alla classe
    %
    % Parametri:
    %   data: matrice numerica con la prima colonna come classe e le altre come features
    %   feature_i: indice della prima feature (escludendo la colonna della classe)
    %   feature_j: indice della seconda feature (escludendo la colonna della classe)

    % Controllo che gli indici siano validi
    if feature_i < 1 || feature_j < 1 || feature_i > size(data,2)-1 || feature_j > size(data,2)-1
        error('Gli indici delle feature devono essere tra 1 e %d.', size(data,2)-1);
    end

    % Estrazione delle classi e delle feature selezionate
    classi = data(:,1);
    x = data(:, feature_i + 1); % +1 per compensare la colonna della classe
    y = data(:, feature_j + 1);

    % Creazione dello scatter plot
    figure;
    gscatter(x, y, classi, lines(numel(unique(classi))), 'o', 8);
    title(['Scatterplot Feature ', num2str(feature_i), ' vs Feature ', num2str(feature_j)]);
    xlabel(['Feature ', num2str(feature_i)]);
    ylabel(['Feature ', num2str(feature_j)]);
    legend('show');
    grid on;
end
