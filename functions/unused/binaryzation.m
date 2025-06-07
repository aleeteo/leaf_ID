function binaryImage = binaryzation(inputImage)
    % Controlla se l'immagine è RGB, e la converte in scala di grigi se necessario
    if size(inputImage, 3) == 3
        grayImage = rgb2gray(inputImage);
    else
        grayImage = inputImage;
    end

    % Applica la sogliatura automatica (metodo di Otsu)
    threshold = graythresh(grayImage);
    binaryImage = imbinarize(grayImage, threshold);

    % (Opzionale) Rimuove piccoli oggetti (rumore) - personalizzabile
    binaryImage = bwareaopen(binaryImage, 50);

    % (Opzionale) Chiude piccoli buchi
    binaryImage = imfill(binaryImage, 'holes');
end
