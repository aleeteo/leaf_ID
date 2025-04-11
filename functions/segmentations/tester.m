%chiede in input una cartella di immagini e una cartella di destinazione

function tester(inputFolder, outputFolder)
    % Controlla se la cartella di input esiste
    if ~isfolder(inputFolder)
        error('La cartella di input non esiste: %s', inputFolder);
    end

    % Controlla se la cartella di output esiste, altrimenti la crea
    if ~isfolder(outputFolder)
        fprintf('La cartella di output "%s" non esiste. La creo...\n', outputFolder);
        mkdir(outputFolder);
    end
    fprintf('Inizio a segmentare \n');
    % Estensioni supportate
    imageExtensions = {'*.jpg', '*.png', '*.bmp', '*.tif'};

    % Elenco dei file immagine
    imageFiles = [];
    for i = 1:length(imageExtensions)
        imageFiles = [imageFiles; dir(fullfile(inputFolder, imageExtensions{i}))];
    end

    % Se non ci sono immagini
    if isempty(imageFiles)
        disp('Nessuna immagine trovata nella cartella di input.');
        return;
    end

    % Ciclo su ogni immagine
    for i = 1:length(imageFiles)
        imageName = imageFiles(i).name;
        imagePath = fullfile(inputFolder, imageName);

        % Crea il nome della maschera
        [~, name, ~] = fileparts(imageName);
        outputFileName = fullfile(outputFolder, [name '_mask.png']);

        % Verifica se la maschera esiste già
        if exist(outputFileName, 'file')
            disp(['La maschera per l''immagine ', imageName, ' esiste già. La salto.']);
            continue;  % Salta questa immagine
        end

        % Legge l'immagine
        img = imread(imagePath);

        % Applica la funzione di segmentazione (assumendo che segmentation2 restituisca la maschera)
        binaryImage = segmentation4(img);  % Restituisce la maschera

        % Salva l'immagine binaria (la maschera)
        imwrite(binaryImage, outputFileName);

        % Notifica
        fprintf('✔ Maschera salvata: %s\n', outputFileName);
    end
    fprintf('tutte le maschere analizzate \n');
end
