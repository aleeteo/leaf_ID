function [mediaacc] = accuracy_final2(inputFolder, foldergt, threshold)
    % Verifiche iniziali
    if ~isfolder(inputFolder)
        error('La cartella di input non esiste: %s', inputFolder);
    end

    if ~isfolder(foldergt)
        error('La cartella di ground truth non esiste: %s', foldergt);
    end

    if threshold == 0
        error('La soglia non può essere nulla');
    end

    % Inizializzazione variabili
    media = 0;
    numFiles = 0;

    % Ottieni i path completi dei file di input e ground truth
    filesInput = getFilePaths(inputFolder);
    filesGT = getFilePaths(foldergt);

    % Crea mappa nome base → path ground truth
    gtMap = containers.Map();
    for i = 1:length(filesGT)
    [~, name, ~] = fileparts(filesGT{i});
    
    % Rimuovi il suffisso '_mask' se presente
    if endsWith(name, '_mask')
        name = extractBefore(name, '_mask');
    end

    gtMap(name) = filesGT{i};
end


    % Cicla su ogni file di input
    for k = 1:length(filesInput)
        imagePath = filesInput{k};
        [~, name, ~] = fileparts(imagePath);

        % Verifica se esiste il GT corrispondente
        if isKey(gtMap, name)
            img = imread(imagePath);
            gt = imread(gtMap(name));

            % Applica la funzione di segmentazione
            mask = segmentation5(img, threshold);

            % Controlla che le dimensioni corrispondano
            if isequal(size(mask), size(gt))
                % Calcola accuratezza
                acc = sum(logical(mask(:)) == logical(gt(:))) / numel(mask);
                media = media + acc;
                numFiles = numFiles + 1;
                disp(['Elaborato: ', name, ' - Accuratezza: ', num2str(acc)]);
            else
                warning('Dimensioni non corrispondenti: %s vs %s. Saltato.', imagePath, gtMap(name));
            end
        else
            disp(['Ground truth mancante per: ', name]);
        end
    end

    % Calcolo media finale
    if numFiles > 0
        mediaacc = media / numFiles;
        disp(['Accuratezza media: ', num2str(mediaacc)]);
    else
        disp('Nessun file elaborato.');
        mediaacc = NaN;
    end
end
