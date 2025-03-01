function manual_threshold_segmentation(image_path, save_path)
    % Carica l'immagine
    img = imread(image_path);
    gray_img = rgb2gray(img);
    
    % Crea una figura con una posizione migliore per gli elementi UI
    fig = figure('Name', 'Segmentazione Interattiva', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 800, 700], 'KeyPressFcn', @keyPressCallback);

    % Asse per l'immagine
    ax = axes('Parent', fig, 'Position', [0.1, 0.3, 0.8, 0.6]); % Ora più in alto
    
    % Slider per la soglia
    uicontrol('Style', 'text', 'Position', [350, 200, 100, 20], 'String', 'Soglia');
    threshold_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 255, 'Value', 128, ...
                                 'Position', [150, 180, 500, 20], ...
                                 'Callback', @(src, event) updateMask());
                             
    % Checkbox per usare la morfologia
    morphology_check = uicontrol('Style', 'checkbox', 'Position', [350, 140, 150, 20], ...
                                 'String', 'Usa Morfologia', 'Value', 1, ...
                                 'Callback', @(src, event) updateMask());

    % Bottone per salvare la maschera
    uicontrol('Style', 'pushbutton', 'String', 'Salva Maschera', ...
              'Position', [300, 100, 200, 40], ...
              'Callback', @(src, event) saveMask());

    % Funzione di aggiornamento della maschera con overlay
    function updateMask()
        threshold = get(threshold_slider, 'Value'); % Ottieni la soglia
        mask = gray_img < threshold; % Applica la soglia
        
        % Applica la morfologia se selezionata
        if get(morphology_check, 'Value')
            mask = bwareaopen(mask, 500); % Rimuove piccoli oggetti
            mask = imfill(mask, 'holes'); % Riempie i buchi
            se = strel('disk', 3);
            mask = imclose(mask, se); % Chiude piccoli buchi
            mask = imopen(mask, se);  % Rimuove dettagli fini indesiderati
        end
        
        % Visualizza overlay dell'immagine originale con la maschera
        imshow(img, 'Parent', ax); % Mostra immagine originale
        hold on;
        maskOverlay = imshow(cat(3, ones(size(mask)) * 1, zeros(size(mask)), zeros(size(mask)))); % Rosso trasparente
        set(maskOverlay, 'AlphaData', mask * 0.5); % Opacità 50%
        hold off;
        
        % Aggiorna titolo con il valore della soglia
        title(ax, sprintf('Soglia: %d', round(threshold)));
    end

    % Funzione per salvare la maschera finale
    function saveMask()
        threshold = get(threshold_slider, 'Value'); % Ottieni la soglia
        mask = gray_img < threshold; % Applica la soglia
        
        if get(morphology_check, 'Value')
            mask = bwareaopen(mask, 500);
            mask = imfill(mask, 'holes');
            se = strel('disk', 3);
            mask = imclose(mask, se);
            mask = imopen(mask, se);
        end
        
        % Salva la maschera come immagine PNG
        imwrite(mask, save_path);
        disp(['✅ Maschera salvata in: ', save_path]);
        
        % Chiude la finestra dopo il salvataggio
        close(fig);
    end

    % Callback per gestione tasti
    function keyPressCallback(~, event)
        if strcmp(event.Key, 'return') % Se l'utente preme Invio
            saveMask(); % Salva la maschera e chiude la finestra
        end
    end

    % Inizializza la visualizzazione
    updateMask();
end