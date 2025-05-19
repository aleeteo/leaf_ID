function accuracy_segmentation(folder1, folder2)
    % Confronta maschere binarie in due cartelle e calcola l'accuratezza percentuale

    files1 = dir(fullfile(folder1, '*.png')); % puoi cambiare estensione se serve
    files2 = dir(fullfile(folder2, '*.png'));
    
    if length(files1) ~= length(files2)
        error('Le due cartelle non contengono lo stesso numero di file.');
    end

    total_accuracy = 0;
    num_files = length(files1);

    fprintf('Confronto %d maschere...\n', num_files);

    for i = 1:num_files
        name1 = files1(i).name;
        name2 = files2(i).name;

        % Verifica che i nomi corrispondano
        if ~strcmp(name1, name2)
            warning('File %s e %s non corrispondono, saltati.\n', name1, name2);
            continue;
        end

        % Leggi le immagini binarie
        mask1 = imread(fullfile(folder1, name1));
        mask2 = imread(fullfile(folder2, name2));

        % Converti in logico se necessario
        if ~islogical(mask1)
            mask1 = imbinarize(mask1);
        end
        if ~islogical(mask2)
            mask2 = imbinarize(mask2);
        end

        % Verifica dimensioni
        if any(size(mask1) ~= size(mask2))
            warning('Le dimensioni di %s non corrispondono. Saltato.\n', name1);
            continue;
        end

        % Calcola accuratezza
        equal_pixels = sum(mask1(:) == mask2(:));
        total_pixels = numel(mask1);
        accuracy = (equal_pixels / total_pixels) * 100;

        total_accuracy = total_accuracy + accuracy;

        fprintf('File %s -> Accuratezza: %.2f%%\n', name1, accuracy);
    end

    % Accuratezza media
    mean_accuracy = total_accuracy / num_files;
    fprintf('\nAccuratezza media su %d immagini: %.2f%%\n', num_files, mean_accuracy);
end
