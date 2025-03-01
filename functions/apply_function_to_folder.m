function apply_function_to_folder(inputDir, outputDir, funcHandle)
% Funzione che applica una funzione a tutte le immagini in una cartella
% (incluse le sottocartelle) e salva il risultato nella struttura corrispondente.

% Creazione della cartella di output se non esiste
if ~exist(outputDir, 'dir')
  mkdir(outputDir);
end

% Chiamata ricorsiva per elaborare tutte le cartelle e i file
process_folder(inputDir, outputDir, funcHandle);

disp('Elaborazione completata!');
end

function process_folder(currentInputDir, currentOutputDir, funcHandle)
% Funzione ricorsiva per elaborare cartelle e immagini

% Creare la cartella di output corrispondente
if ~exist(currentOutputDir, 'dir')
  mkdir(currentOutputDir);
end

% Ottenere la lista di tutti i file e cartelle nella directory corrente
items = dir(currentInputDir);

for i = 1:length(items)
  if items(i).name(1) == '.'  % Ignora '.' e '..'
    continue;
  end

  itemPath = fullfile(currentInputDir, items(i).name);
  outputPath = fullfile(currentOutputDir, items(i).name);

  if items(i).isdir
    % Se è una cartella, entra ricorsivamente
    process_folder(itemPath, outputPath, funcHandle);
  else
    % Se è un'immagine, applica la funzione
    [~, ~, ext] = fileparts(itemPath);
    if ismember(lower(ext), {'.jpg', '.png', '.jpeg', '.bmp', '.tiff'}) % Aggiungere altri formati se necessario
      img = imread(itemPath);
      result = funcHandle(img);
      imwrite(result, outputPath);
      fprintf('File salvato: %s\n', outputPath);
    end
  end
end
end
