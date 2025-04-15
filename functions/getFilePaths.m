function filePaths = getFilePaths(inputDir)
    % getFilePaths - Restituisce i path dei file presenti nella directory
    % specificata da inputDir, sotto forma di stringhe "dir/subdir/file".
    %
    %  filePaths = getFilePaths(inputDir)
    %
    %  inputDir:   Directory di cui estrarre i file
    %  filePaths:  Cell array di stringhe con i path dei file, 
    %              costruiti come "dir/subdir/file"

    % 1. Ottieni la lista di file e directory presenti in inputDir
    items = dir(inputDir);

    % 2. Rimuovi le voci speciali '.' e '..'
    items(ismember({items.name}, {'.','..'})) = [];

    % 3. Conta quanti sono i file (non directory)
    numFiles = sum(~[items.isdir]);

    % 4. Prealloca il cell array con dimensione esatta
    filePaths = cell(numFiles, 1);

    % 5. Riempie il cell array con i path dei file
    idx = 1;
    for i = 1:length(items)
        if ~items(i).isdir
            % Costruisce un path come "inputDir/file"
            relativePath = fullfile(inputDir, items(i).name);
            filePaths{idx} = relativePath;
            idx = idx + 1;
        end
    end
end
