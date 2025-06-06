function tresh_accuracy_hist(images_path, masks_path)
    % Controlla che le cartelle esistano
    if ~isfolder(images_path)
        error('La cartella delle immagini non esiste.');
    end
    if ~isfolder(masks_path)
        error('La cartella delle maschere non esiste.');
    end

    % Definizione dei threshold da 1 a 30
    thresholds = 1:30;
    accuracy_values = zeros(size(thresholds));  % Preallocazione
    %creazione contatore per definire il valore massimo di accuracy media
    vmax=0;
    tmax=0;
    % Ciclo su ciascun threshold
    for i = 1:length(thresholds)
        threshold = thresholds(i);
        accuracy = accuracy_final2(images_path, masks_path, threshold);
        if (accuracy>vmax)
            vmax=accuracy;
            tmax=threshold;
        end
        accuracy_values(i) = accuracy;
        fprintf('Threshold = %d -> Accuracy = %.4f\n', threshold, accuracy);
    end
    
    fprintf('Accuratezza Massima %.4f per Threshold %d', vmax, tmax);
    % Crea istogramma
    figure;
    bar(thresholds, accuracy_values, 'FaceColor', [0.2 0.4 0.6]);
    xlabel('Threshold');
    ylabel('Accuracy');
    title('Accuracy vs Threshold');
    grid on;
end
