function hu = compute_hu_moments(mask, varargin)
    % COMPUTE_HU_MOMENTS Calcola i momenti di Hu di un'immagine o maschera.
    % 
    % USO:
    %   hu = compute_hu_moments(mask)
    %   hu = compute_hu_moments(mask, image)
    %   hu = compute_hu_moments(mask, image, 'max_order', N)
    %
    % INPUT:
    %   - mask:      Matrice binaria che definisce la regione di interesse (obbligatorio).
    %   - image:     Immagine originale (opzionale, default = []).
    %
    % PARAMETRI OPZIONALI (Name-Value Pairs):
    %   - 'max_order': Numero massimo di momenti di Hu da calcolare (default = 7).
    %
    % OUTPUT:
    %   - hu: Vettore contenente i momenti di Hu fino a max_order.
    %
    % ESEMPIO:
    %   mask = imread('mask.png'); 
    %   image = imread('image.png'); 
    %   hu = compute_hu_moments(mask, image, 'max_order', 5);
    
    % Parser per gli input
    p = inputParser;
    addRequired(p, 'mask', @(x) (isnumeric(x) || islogical(x)) && ismatrix(x));
    addOptional(p, 'image', [], @(x) isnumeric(x) && (ismatrix(x) || ndims(x) == 3));
    addParameter(p, 'max_order', 7, @(x) isnumeric(x) && isscalar(x) && x >= 1 && x <= 7);
    parse(p, mask, varargin{:});
    
    mask = double(p.Results.mask);
    image = p.Results.image;
    max_order = p.Results.max_order;
    
    % Se è presente l'immagine applica la maschera
    if ~isempty(image)
        % Se l'immagine è a colori convertila in scala di grigi
        if size(image, 3) ~= 1 
            image = rgb2gray(image);
        end
        % Converto in double e applico la maschera
        img = double(image) .* mask;
    else
        % Se non viene fornita un'immagine, uso solo la maschera
        img = mask;
    end
    
    % Ottieni la dimensione dell'immagine
    [rows, cols] = size(img);
    [X, Y] = meshgrid(1:cols, 1:rows);

    % Calcola i momenti spaziali
    m00 = sum(img(:)); % Momento di ordine zero (area o intensità totale)
    if m00 == 0
        % Gestione del caso degenere (evita divisioni per zero)
        hu = zeros(1, max_order);
        return;
    end
    m10 = sum(sum(X .* img));
    m01 = sum(sum(Y .* img));

    % Calcola il centroide
    xc = m10 / m00;
    yc = m01 / m00;

    % Calcola i momenti centrali fino all'ordine massimo specificato
    mu20 = sum(sum(((X - xc).^2) .* img));
    mu02 = sum(sum(((Y - yc).^2) .* img));
    mu11 = sum(sum(((X - xc) .* (Y - yc)) .* img));
    
    if max_order >= 3
        mu30 = sum(sum(((X - xc).^3) .* img));
        mu03 = sum(sum(((Y - yc).^3) .* img));
        mu21 = sum(sum(((X - xc).^2 .* (Y - yc)) .* img));
        mu12 = sum(sum(((X - xc) .* (Y - yc).^2) .* img));
    end

    % Calcola i momenti centrali normalizzati per l'invarianza rispetto alla scala
    eta20 = mu20 / m00^2;
    eta02 = mu02 / m00^2;
    eta11 = mu11 / m00^2;
    
    if max_order >= 3
        eta30 = mu30 / m00^(2.5);
        eta03 = mu03 / m00^(2.5);
        eta21 = mu21 / m00^(2.5);
        eta12 = mu12 / m00^(2.5);
    end

    % Calcola i momenti di Hu fino a max_order
    hu = zeros(1, max_order);
    hu(1) = eta20 + eta02;
    if max_order >= 2
        hu(2) = (eta20 - eta02)^2 + 4 * eta11^2;
    end
    if max_order >= 3
        hu(3) = (eta30 - 3 * eta12)^2 + (3 * eta21 - eta03)^2;
    end
    if max_order >= 4
        hu(4) = (eta30 + eta12)^2 + (eta21 + eta03)^2;
    end
    if max_order >= 5
        hu(5) = (eta30 - 3 * eta12) * (eta30 + eta12) * ((eta30 + eta12)^2 - 3 * (eta21 + eta03)^2) + ...
                (3 * eta21 - eta03) * (eta21 + eta03) * (3 * (eta30 + eta12)^2 - (eta21 + eta03)^2);
    end
    if max_order >= 6
        hu(6) = (eta20 - eta02) * ((eta30 + eta12)^2 - (eta21 + eta03)^2) + ...
                4 * eta11 * (eta30 + eta12) * (eta21 + eta03);
    end
    if max_order >= 7
        hu(7) = (3 * eta21 - eta03) * (eta30 + eta12) * ((eta30 + eta12)^2 - 3 * (eta21 + eta03)^2) - ...
                (eta30 - 3 * eta12) * (eta21 + eta03) * (3 * (eta30 + eta12)^2 - (eta21 + eta03)^2);
    end
end

