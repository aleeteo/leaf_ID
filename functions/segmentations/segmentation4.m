function mask = segmentation4(img)
%segmenta l'immagine usando region growing con colore
    fprintf('inizio a segmentare questa immagine \n');
    % Verifica se l'immagine è RGB
    if size(img, 3) ~= 3
        error('L''immagine in input deve essere RGB.');
    end

    % Converte l'immagine in spazio colore LAB
    lab_img = rgb2lab(img);

    % Estrai i canali a e b (componenti cromatiche)
    a = lab_img(:,:,2);
    b = lab_img(:,:,3);

    % Seme: pixel in alto a sinistra (riga 1, colonna 1)
    seed_color = [a(1,1), b(1,1)];

    % Parametro soglia per similarità cromatica
    threshold = 10;

    % Inizializzazione maschere
    [rows, cols] = size(a);
    visited = false(rows, cols);
    background_mask = false(rows, cols);

    % Coda per pixel da esplorare (FIFO queue)
    queue = [1, 1];
    visited(1, 1) = true;
    background_mask(1, 1) = true;

    % Region growing
    while ~isempty(queue)
        % Estrai il primo pixel dalla coda
        pixel = queue(1, :);
        queue(1, :) = [];

        row = pixel(1);
        col = pixel(2);

        % Esplora vicini (8 connettività)
        for i = -1:1
            for j = -1:1
                r = row + i;
                c = col + j;

                % Salta il pixel stesso e controlla limiti immagine
                if (r >= 1 && r <= rows && c >= 1 && c <= cols && ~visited(r,c))
                    color = [a(r,c), b(r,c)];
                    dist = sqrt(sum((color - seed_color).^2));

                    if dist < threshold
                        visited(r,c) = true;
                        background_mask(r,c) = true;
                        queue(end+1, :) = [r, c];  % Aggiungi il pixel alla coda
                    end
                end
            end
        end
    end

    % Maschera oggetti (non sfondo)
    mask = ~background_mask;

    % Pulizia opzionale
    mask = bwareaopen(mask, 50);     % Rimuove piccoli oggetti
    mask = imfill(mask, 'holes');    % Riempie buchi
end

