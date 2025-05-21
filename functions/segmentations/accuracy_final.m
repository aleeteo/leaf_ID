function [mediaacc] = accuracy_final(inputFolder, foldergt, threshold)
    % Controlla se la cartella di input esiste
    if ~isfolder(inputFolder)
        error('La cartella di input non esiste: %s', inputFolder);
    end

    % Controlla se la cartella di ground truth esiste
    if ~isfolder(foldergt)
        error('La cartella di ground truth non esiste: %s', foldergt);
    end

    % Estensioni supportate
    imageExtensions = {'*.jpg', '*.png', '*.bmp', '*.tif'};
    media = 0;
    numFiles = 0;

    % Controlla se la threshold è diversa da 0
    if threshold == 0
        error('La soglia non può essere nulla');
    end

    % Ciclo su ogni estensione di file supportata
    for ext = imageExtensions
        % Ottieni l'elenco dei file nella cartella di input con l'estensione corrente
        files = dir(fullfile(inputFolder, ext{1}));

        % Verifica se sono stati trovati file
        if ~isempty(files)
            % Ciclo su ogni file
            for k = 1:length(files)
                % Costruisci il percorso completo del file
                imagePath = fullfile(files(k).folder, files(k).name);
                img = imread(imagePath);

                % Applica la funzione segmentation5
                mask = segmentation5(img, threshold);

                % Costruisci il percorso del file ground truth corrispondente
                gtPath = fullfile(foldergt, files(k).name);

                % Verifica se il file ground truth esiste
                if isfile(gtPath)
                    % Carica il ground truth
                    gt = imread(gtPath);

                    % Verifica che le dimensioni delle immagini corrispondano
                    if ~isequal(size(mask), size(gt))
                        warning('Le dimensioni di %s e %s non corrispondono. Immagini saltate.', files(k).name, gtPath);
                        continue;
                    end

                    % Calcola l'accuratezza
                    acc = sum(mask(:) == gt(:)) / numel(mask);
                    media = media + acc;
                    numFiles = numFiles + 1;
                    disp(['Elaborato: ', files(k).name, ' - Accuratezza: ', num2str(acc)]);
                else
                    disp(['File ground truth mancante per: ', files(k).name]);
                end
            end
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
