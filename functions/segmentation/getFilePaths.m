function filePaths = getFilePaths(inputDir)
% getFilePaths - Restituisce i path dei file presenti nella directory
% specificata da inputDir, sotto forma di stringhe "dir/subdir/file",
% ignorando . e .. e .DS_Store.
%
%  filePaths = getFilePaths(inputDir)
%
%  inputDir:   Directory in cui cercare i file
%  filePaths:  Cell array di stringhe con i path dei file

% 1. Ottieni la lista degli elementi (file/dir)
  % inputDir = char(inputDir);  % ✅ Cast esplicito
  items = dir(inputDir);
  
  % 2. Rimuovi le voci speciali '.' , '..' e '.DS_Store'
  items(ismember({items.name}, {'.','..','.DS_Store'})) = [];
  
  % 3. Conta i file effettivi
  numFiles = sum(~[items.isdir]);
  
  % 4. Prealloca il cell array per i path
  filePaths = cell(numFiles, 1);
  
  % 5. Riempie il cell array con i path dei file
  idx = 1;
  for i = 1:length(items)
    if ~items(i).isdir
      % Costruisce il path "inputDir/file"
      fullPath = fullfile(inputDir, items(i).name);
      filePaths{idx} = fullPath;
      idx = idx + 1;
    end
  end
end
