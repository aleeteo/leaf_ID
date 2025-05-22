function thresaccu_isto(images_path, masks_path)
    % Controlla che le cartelle esistano
    if ~isfolder(images_path)
        error('La cartella delle immagini non esiste.');
    end
    if ~isfolder(masks_path)
        error('La cartella delle maschere non esiste.');
    end

    % Definizione dei threshold da 1 a 5
    thresholds = 1:5;
    accuracy_values = zeros(size(thresholds));  % Preallocazione

    % Ciclo su ciascun threshold
    for i = 1:length(thresholds)
        threshold = thresholds(i);
        accuracy = accuracy_final(images_path, masks_path, threshold);
        accuracy_values(i) = accuracy;
        fprintf('Threshold = %d -> Accuracy = %.4f\n', threshold, accuracy);
    end

    % Crea istogramma
    figure;
    bar(thresholds, accuracy_values, 'FaceColor', [0.2 0.4 0.6]);
    xlabel('Threshold');
    ylabel('Accuracy');
    title('Accuracy vs Threshold');
    grid on;
end
