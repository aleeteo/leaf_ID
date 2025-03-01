function batch_label_regions(image_folder, mask_folder, output_folder)
    % Funzione per etichettare in batch le regioni segmentate di più immagini
    % image_folder: cartella contenente le immagini originali
    % mask_folder: cartella contenente le maschere binarie
    % output_folder: cartella dove salvare le etichette in formato .mat

    % Creazione cartella di output se non esiste
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Legge tutte le immagini originali nella cartella
    image_files = dir(fullfile(image_folder, '*.jpg')); 
    
    for k = 1:length(image_files)
        % Nome del file senza estensione
        [~, name, ~] = fileparts(image_files(k).name);
        
        % Percorsi completi delle immagini e maschere
        image_path = fullfile(image_folder, image_files(k).name);
        mask_path = fullfile(mask_folder, strcat(name, '_mask.png'));
        output_path = fullfile(output_folder, strcat(name, '_label.mat'));
        
        % Verifica se il file label esiste già, se sì, lo salta
        if isfile(output_path)
            fprintf('Label già presente per %s. Saltata.\n', name);
            continue;
        end
        
        % Verifica che la maschera esista
        if ~isfile(mask_path)
            warning('Maschera %s non trovata. Saltata.', mask_path);
            continue;
        end
        
        % Carica immagine e maschera
        im = imread(image_path);
        BW = imread(mask_path);
        
        % Chiama la funzione label_regions
        labeledImage = label_regions(BW, im);
        
        % Salva il risultato
        save(output_path, 'labeledImage');
    end
    
    disp('Processo completato! Tutte le immagini sono state etichettate.');
end