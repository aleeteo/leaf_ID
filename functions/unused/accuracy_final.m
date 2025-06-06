function [mediaacc] = accuracy_final(inputFolder, foldergt, threshold)
    %Check di controllo Necessari-------------------------------
    % Controlla se la cartella di input esiste
    if ~isfolder(inputFolder)
        error('La cartella di input non esiste: %s', inputFolder);
    end

    % Controlla se la cartella di ground truth esiste
    if ~isfolder(foldergt)
        error('La cartella di ground truth non esiste: %s', foldergt);
    end
    % Controlla se la threshold è diversa da 0
    if threshold == 0
        error('La soglia non può essere nulla');
    end
    %-----------------------------------------------------------
    
    % Estensioni supportate
    imageExtensions = {'*.jpg', '*.png', '*.bmp', '*.tif'};
    media = 0;
    numFiles = 0;

    

    % Ottieni l'elenco dei file nella cartella di input
    files = getFilePaths(inputFolder);

    disp("fino a qui ok");

    % Verifica se sono stati trovati file
    if isempty(files)
        disp('Nessun file trovato nella cartella di input.');
        return;
    end
    %ottieni elenco file gt
    filesGT=getFilePaths(foldergt);






    % Ciclo su ogni file
    for k = 1:length(files)
        % Costruisci il percorso completo del file
        imagePath = files(k);
        img = imread(imagePath);

        % Applica la funzione segmentation5
        mask = segmentation5(img, threshold);

        % Costruisci il nome del file ground truth corrispondente
        gtPath = filesGT(k);

        % Verifica se il file ground truth esiste
        if isfile(gtPath)
            % Carica il ground truth
            gt = imread(gtPath);

            % Verifica che le dimensioni delle immagini corrispondano
            if isequal(size(mask), size(gt))
                % Calcola l'accuratezza
                acc = sum(mask(:) == gt(:)) / numel(mask);
                media = media + acc;
                numFiles = numFiles + 1;
                disp(['Elaborato: ', files(k).name, ' - Accuratezza: ', num2str(acc)]);
            else
                warning('Le dimensioni di %s e %s non corrispondono. Immagini saltate.', files(k).name, gtPath);
            end
        else
            disp(['File ground truth mancante per: ', files(k).name]);
        end
    end

    % Calcola la media delle accuratezze
    if numFiles > 0
        mediaacc = media / numFiles;
        disp(['Accuratezza media: ', num2str(mediaacc)]);
    else
        disp('Nessun file elaborato.');
        mediaacc = NaN;
    end
end

