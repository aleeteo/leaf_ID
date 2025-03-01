function manual_threshold_segmentation_r(image_path, save_path)
    % Carica l'immagine
    img = imread(image_path);
    gray_img = rgb2gray(img);
    
    % Crea la finestra grafica
    fig = figure('Name', 'Segmentazione Interattiva', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 900, 750], 'KeyPressFcn', @keyPressCallback);

    % Asse per l'immagine
    ax = axes('Parent', fig, 'Position', [0.1, 0.3, 0.8, 0.6]); % Più spazio per i bottoni sotto
    imshow(img, 'Parent', ax); % Mostra solo l'immagine originale

    % Maschera iniziale
    mask = false(size(gray_img));

    % Slider per la soglia
    uicontrol('Style', 'text', 'Position', [350, 200, 100, 20], 'String', 'Soglia');
    threshold_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 255, 'Value', 128, ...
                                 'Position', [150, 180, 500, 20], ...
                                 'Callback', @(src, event) updateMask());

    % Checkbox per morfologia
    morphology_check = uicontrol('Style', 'checkbox', 'Position', [350, 140, 150, 20], ...
                                 'String', 'Usa Morfologia', 'Value', 1, ...
                                 'Callback', @(src, event) updateMask());

    % **Pulsanti Centrati**
    button_width = 200;
    button_height = 50;
    button_y = 80;
    screen_center_x = 450;

    % Pulsante per salvare e chiudere
    uicontrol('Style', 'pushbutton', 'String', 'Salva Maschera', ...
              'Position', [screen_center_x - button_width / 2, button_y, button_width, button_height], ...
              'FontSize', 12, 'Callback', @(src, event) saveMask());

    % Funzione per aggiornare la maschera
    function updateMask()
        threshold = get(threshold_slider, 'Value'); 
        mask = gray_img < threshold; 
        
        % Morfologia opzionale
        if get(morphology_check, 'Value')
            mask = bwareaopen(mask, 500); 
            mask = imfill(mask, 'holes'); 
            se = strel('disk', 3);
            mask = imclose(mask, se);
            mask = imopen(mask, se);
        end
        
        % Visualizza la maschera sovrapposta
        imshow(img, 'Parent', ax);
        hold on;
        maskOverlay = imshow(cat(3, ones(size(mask)), zeros(size(mask)), zeros(size(mask))));
        set(maskOverlay, 'AlphaData', double(mask) * 0.5);
        hold off;
    end

    % Funzione per salvare la maschera e chiedere se modificarla
    function saveMask()
        imwrite(mask, save_path);
        disp(['✅ Maschera salvata in: ', save_path]);
        close(fig);

        % **Dopo il salvataggio, chiedere se si vuole modificare la maschera**
        choice = questdlg('Vuoi modificare la maschera?', ...
                          'Modifica Maschera', 'Sì', 'No', 'No');

        % Se l'utente sceglie "Sì", chiama `refine_mask`
        if strcmp(choice, 'Sì')
            refine_mask(image_path, save_path);
        end
    end

    % Callback per chiusura con Invio
    function keyPressCallback(~, event)
        if strcmp(event.Key, 'return')
            saveMask();
        end
    end

    % Inizializza la visualizzazione
    updateMask();
end