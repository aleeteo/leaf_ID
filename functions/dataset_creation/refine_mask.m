function refine_mask(image_path, mask_path)
    % Carica l'immagine originale e la maschera esistente
    img = imread(image_path);
    mask = imread(mask_path) > 0; % Converti in binario
    
    % Crea la finestra grafica
    fig = figure('Name', 'Modifica Maschera', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 900, 750], 'KeyPressFcn', @keyPressCallback); % Aumentata la larghezza

    % Asse per l'immagine
    ax = axes('Parent', fig, 'Position', [0.1, 0.3, 0.8, 0.6]); % Più spazio per i bottoni sotto
    img_handle = imshow(img, 'Parent', ax); % Mostra solo l'immagine originale

    % Overlay iniziale della maschera
    hold on;
    maskOverlay = imshow(cat(3, ones(size(mask)), zeros(size(mask)), zeros(size(mask)))); % Rosso trasparente
    set(maskOverlay, 'AlphaData', double(mask) * 0.3);
    hold off;

    % **Definizione della posizione dei pulsanti centrati**
    button_width = 200;  % Larghezza pulsanti
    button_height = 50;  % Altezza pulsanti
    button_y = 80;       % Posizione verticale dei pulsanti (più centrato)
    screen_center_x = 450; % Centro della finestra

    % Pulsante per aggiungere area
    uicontrol('Style', 'pushbutton', 'String', 'Aggiungi Area', ...
              'Position', [screen_center_x - button_width - 20, button_y, button_width, button_height], ...
              'FontSize', 12, 'Callback', @(src, event) editMask('add'));

    % Pulsante per rimuovere area
    uicontrol('Style', 'pushbutton', 'String', 'Rimuovi Area', ...
              'Position', [screen_center_x + 20, button_y, button_width, button_height], ...
              'FontSize', 12, 'Callback', @(src, event) editMask('remove'));

    % Funzione per editing manuale
    function editMask(mode)
        disp(['Seleziona l''area da ', mode, ' con il mouse']);

        % Selettore manuale sulla vera immagine originale
        h = drawfreehand(ax, 'Color', 'g', 'LineWidth', 1);
        wait(h); % Aspetta la conferma dell'utente

        % Controllo se l'oggetto è stato cancellato
        if ~isvalid(h)
            disp('❌ Selezione annullata. Nessuna modifica effettuata.');
            return;
        end

        % **Crea la maschera dalla selezione, specificando l'immagine originale**
        user_mask = createMask(h, img_handle); 

        % **Apporta le modifiche alla maschera principale**
        if strcmp(mode, 'add')
            mask = mask | user_mask; % Aggiunge la selezione
        elseif strcmp(mode, 'remove')
            mask = mask & ~user_mask; % Rimuove la selezione
        end

        % Aggiorna l'overlay esistente, senza crearne uno nuovo
        set(maskOverlay, 'CData', cat(3, ones(size(mask)), zeros(size(mask)), zeros(size(mask))));
        set(maskOverlay, 'AlphaData', double(mask) * 0.3);
    end

    % Funzione per salvare la maschera
    function saveMask()
        imwrite(mask, mask_path);
        disp(['✅ Maschera modificata salvata in: ', mask_path]);
        close(fig);
    end

    % Callback per chiusura con Invio
    function keyPressCallback(~, event)
        if strcmp(event.Key, 'return')
            saveMask();
        end
    end
end