function [features, feature_names] = compute_shape_descriptors(img, mask)
    % Controllo input
    if nargin < 1
        error('Devi fornire una maschera binaria.');
    end
    
    % Etichettatura della regione connessa nella maschera
    stats = regionprops(mask, 'Area', 'Perimeter', 'Eccentricity');

    % Controllo che la maschera contenga almeno un oggetto
    if isempty(stats)
        error('La maschera non contiene oggetti validi.');
    end
    
    % Estrazione delle proprietà
    area = stats.Area;
    perimetro = stats.Perimeter;
    eccentricity = stats.Eccentricity;
    
    % Calcolo compattezza e circolarità
    compactness = (perimetro^2) / area;
    circularity = (4 * pi * area) / (perimetro^2);

    hu = compute_hu_moments(mask);
    hu_names = {'HuMoment1', 'HuMoment2', 'HuMoment3', 'HuMoment4', ...
                'HuMoment5', 'HuMoment6', 'HuMoment7'};
    hu_gray = compute_hu_moments(mask, img);
    hu_gray_names = {'Hu_gray_1', 'Hu_gray_2', 'Hu_gray_3', 'Hu_gray_4', ...
                     'Hu_gray_5', 'Hu_gray_6', 'Hu_gray_7'};
    
    % Creazione del vettore delle features
    features = [compactness, circularity, eccentricity, ...
                hu, hu_gray];
    
    % Creazione del vettore dei nomi delle features
    feature_names = [{'Compactness', 'Circularity', 'Eccentricity'}, ...
                     hu_names, hu_gray_names];
end

