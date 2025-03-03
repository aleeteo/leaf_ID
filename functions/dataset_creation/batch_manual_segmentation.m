function batch_manual_segmentation(input_folder, output_folder)
    % Controlla se la cartella di output esiste, altrimenti la crea
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Ottieni la lista di tutte le immagini nella cartella di input
    image_files = dir(fullfile(input_folder, '*.jpg')); % Cambia estensione se necessario
    num_images = length(image_files);
    
    if num_images == 0
        disp('Nessuna immagine trovata nella cartella specificata.');
        return;
    end

    % Itera su ogni immagine
    for i = 1:num_images
        % Costruisci i percorsi dei file
        img_name = image_files(i).name;
        img_path = fullfile(input_folder, img_name);
        mask_path = fullfile(output_folder, strrep(img_name, '.jpg', '_mask.png')); % Salva in PNG

        % Se la maschera esiste già, skippa automaticamente
        if exist(mask_path, 'file')
            fprintf('✓ Maschera già esistente, salto: %s\n', img_name);
            continue;
        end

        % Mostra progresso
        fprintf('▶ Elaborazione immagine %d/%d: %s\n', i, num_images, img_name);
        
        % Avvia la segmentazione interattiva
        manual_threshold_segmentation(img_path, mask_path);

        % Attendere input per passare all'immagine successiva o permettere di saltare
        disp('Premi un tasto per continuare, "s" per saltare l''immagine...');
        key = input('', 's'); % Input dell'utente (come stringa)

        % Se l'utente preme "s", cancella il file e passa oltre
        if strcmpi(key, 's')
            fprintf('⏩ Immagine %s saltata manualmente.\n', img_name);
            continue;
        end
    end
    
    disp('✅ Processo completato!');
end