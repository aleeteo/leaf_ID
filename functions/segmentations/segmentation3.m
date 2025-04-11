function mask = segmentation3(img)
%segmenta l'immagine usando region growing con luminosità e colore
    % Verifica se l'immagine è RGB
    if size(img, 3) ~= 3
        error('L''immagine in input deve essere RGB.');
    end

    % Converte l'immagine in spazio colore LAB
    lab_img = rgb2lab(img);

    % Estrai i canali L, a e b
    L = lab_img(:,:,1);
    a = lab_img(:,:,2);
    b = lab_img(:,:,3);

    % Estrai il pixel in alto a sinistra (usato come riferimento)
    ref_pixel = lab_img(1, 1, :);
    ref_pixel = ref_pixel(:);  % 3x1

    % Definisci il parametro di crescita della regione
    region_threshold = 10;  % Soglia per la similarità dei colori (modifica se necessario)

    % Region Growing: crescita a partire dal primo pixel (basato su L, a, b)
    mask_region_growing = regionGrowing(L, a, b, ref_pixel, region_threshold);

    % Estrai la matrice delle caratteristiche per il clustering (canali L, a, b)
    feature_matrix = [L(:), a(:), b(:)];

    % K-means clustering con 2 cluster (sfondo e oggetti)
    k = 2;
    [cluster_idx, cluster_centers] = kmeans(feature_matrix, k, 'Replicates', 3);

    % Riporta i cluster alla dimensione dell'immagine
    cluster_idx = reshape(cluster_idx, size(L));

    % Determina il cluster più vicino al pixel di riferimento (sfondo)
    distances = vecnorm(cluster_centers - ref_pixel', 2, 2);
    [~, background_idx] = min(distances); % Il cluster più vicino è il "background"

    % Crea la maschera binaria (sfondo vs oggetti)
    mask = cluster_idx ~= background_idx;

    % Combina la maschera di region growing con la maschera del clustering
    mask = mask & mask_region_growing;

    % Pulizia della maschera (opzionale)
    mask = bwareaopen(mask, 50);  % Rimuove piccoli oggetti
    mask = imfill(mask, 'holes');  % Riempi i buchi all'interno degli oggetti
end

% Funzione Region Growing
function mask = regionGrowing(L, a, b, ref_pixel, threshold)
    % Inizializza la maschera vuota
    mask = false(size(L));

    % Crea una lista di pixel da esplorare (inizialmente solo il pixel di riferimento)
    [rows, cols] = size(L);
    explored = false(rows, cols);
    to_explore = [1, 1];  % Comincia dal primo pixel
    explored(1, 1) = true;
    mask(1, 1) = true;

    % Espandi la regione finché ci sono pixel da esplorare
    while ~isempty(to_explore)
        current_pixel = to_explore(1, :);
        to_explore(1, :) = [];  % Rimuovi il primo pixel da esplorare

        % Estrai le coordinate
        row = current_pixel(1);
        col = current_pixel(2);

        % Estrai i valori dei canali L, a, b per il pixel corrente
        current_color = [L(row, col), a(row, col), b(row, col)];

        % Calcola la distanza tra il colore del pixel corrente e il pixel di riferimento
        color_diff = norm(current_color - ref_pixel);

        % Se la differenza è inferiore alla soglia, continua l'esplorazione
        if color_diff < threshold
            % Esplora i vicini (8 connettività)
            for i = -1:1
                for j = -1:1
                    new_row = row + i;
                    new_col = col + j;

                    % Verifica se il nuovo pixel è all'interno dell'immagine
                    if new_row >= 1 && new_row <= rows && new_col >= 1 && new_col <= cols
                        if ~explored(new_row, new_col)
                            explored(new_row, new_col) = true;
                            to_explore = [to_explore; new_row, new_col];  % Aggiungi alla lista di esplorazione
                            mask(new_row, new_col) = true;  % Aggiungi alla regione
                        end
                    end
                end
            end
        end
    end
end
%region growing per colore e luminosità