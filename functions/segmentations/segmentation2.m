function mask = segmentation2(img)
    % Verifica se è RGB
    if size(img, 3) ~= 3
        error('L''immagine in input deve essere RGB.');
    end

    % Converte in spazio colore LAB
    lab_img = rgb2lab(img);

    % Estrai i canali
    L = lab_img(:,:,1);
    a = lab_img(:,:,2);
    b = lab_img(:,:,3);

    % Estrai il pixel in alto a sinistra (usato come riferimento per lo sfondo)
    ref_pixel = lab_img(1,1,:);
    ref_pixel = ref_pixel(:);  % 3x1

    % Costruisci la matrice delle caratteristiche per il clustering
    feature_matrix = [L(:), a(:), b(:)];

    % K-means clustering con 2 cluster
    k = 2;
    [cluster_idx, cluster_centers] = kmeans(feature_matrix, k, 'Replicates', 3);

    % Reshape per riportare i cluster alla forma immagine
    cluster_idx = reshape(cluster_idx, size(L));

    % Calcola la distanza del ref_pixel da ciascun centro cluster
    distances = vecnorm(cluster_centers - ref_pixel', 2, 2);
    [~, background_idx] = min(distances); % lo sfondo è il cluster più vicino al ref_pixel

    % Crea la maschera degli oggetti (complementare dello sfondo)
    mask = cluster_idx ~= background_idx;

    % Pulizia maschera (opzionale)
    mask = bwareaopen(mask, 50);
    mask = imfill(mask, 'holes');
end
