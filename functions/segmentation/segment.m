function mask = segment(img, threshold)
    arguments    
      img(:,:,:)
      threshold(1,1) {mustBeNumeric}=21
    end

    fprintf('Inizio a segmentare questa immagine \n');

    if size(img, 3) ~= 3
        error('L''immagine in input deve essere RGB.');
    end

    % Converte in LAB
    lab_img = rgb2lab(img);
    L = lab_img(:,:,1);
    a = lab_img(:,:,2);
    b = lab_img(:,:,3);

    % Seme: media di una zona in alto a sinistra
    seed_L = mean(L(1:10,1:10), 'all');
    seed_a = mean(a(1:10,1:10), 'all');
    seed_b = mean(b(1:10,1:10), 'all');
    seed_color = [seed_L, seed_a, seed_b];

     

    [rows, cols] = size(L);
    visited = false(rows, cols);
    background_mask = false(rows, cols);

    queue = [1, 1];
    visited(1, 1) = true;
    background_mask(1, 1) = true;

    while ~isempty(queue)
        pixel = queue(1, :);
        queue(1, :) = [];

        row = pixel(1);
        col = pixel(2);

        for i = -1:1
            for j = -1:1
                r = row + i;
                c = col + j;

                if (r >= 1 && r <= rows && c >= 1 && c <= cols && ~visited(r,c))
                    color = [L(r,c), a(r,c), b(r,c)];
                    dist = sqrt((color(1)-seed_color(1))^2 * 0.5 + ...
                                (color(2)-seed_color(2))^2 + ...
                                (color(3)-seed_color(3))^2);

                    if dist < threshold
                        visited(r,c) = true;
                        background_mask(r,c) = true;
                        queue(end+1, :) = [r, c];
                    end
                end
            end
        end
    end

    mask = ~background_mask;
    mask = bwareaopen(mask, 50);
    mask = imfill(mask, 'holes');
end
