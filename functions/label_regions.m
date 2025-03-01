function labeledImage = label_regions(BW, im)
    % Funzione per etichettare manualmente ogni regione connessa
    % BW: immagine binaria segmentata
    % Restituisce un'immagine etichettata con valori assegnati dall'utente
    
    % Trova le regioni connesse
    CC = bwconncomp(BW);
    labeledImage = zeros(size(BW)); % Matrice per le etichette

    % Crea una figura per selezionare le regioni
    figure,
    subplot(2,1,1), imshow(im);
    subplot(2,1,2), imshow(BW);
    hold on;
    
    % Estrai le proprietà delle regioni
    stats = regionprops(CC, 'Centroid');
    
    % Itera su ogni regione trovata
    for i = 1:CC.NumObjects
        % Mostra il numero della regione
        centroid = stats(i).Centroid;
        text(centroid(1), centroid(2), num2str(i), 'Color', 'r', 'FontSize', 12);
    end
    
    hold off;
    
    % Chiedi all'utente di inserire le etichette
    labels = zeros(1, CC.NumObjects);
    for i = 1:CC.NumObjects
        prompt = sprintf('Inserisci la label per la regione %d: ', i);
        labels(i) = input(prompt);
    end
    
    % Assegna le etichette alle regioni
    for i = 1:CC.NumObjects
        labeledImage(CC.PixelIdxList{i}) = labels(i);
    end

    % Visualizza l'immagine etichettata
    figure, imagesc(labeledImage);
    colormap(jet);
    colorbar;
    title('Immagine etichettata');
end