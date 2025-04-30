function texture_table = compute_texture_descriptors(img, mask, options)
% COMPUTE_TEXTURE_DESCRIPTORS Calcola i descrittori di texture da un'immagine.
%
%   texture_table = COMPUTE_TEXTURE_DESCRIPTORS(img, mask, options) restituisce una tabella
%   con le statistiche dell'istogramma, GLCM, LBP e edge gradienti a seconda delle opzioni.
%
%   Parametri in options:
%     - texture_features: cell array con i blocchi da attivare tra:
%         'hist'   : statistiche dell'istogramma (mean, var, ecc.)
%         'glcm'   : GLCM features (contrast, correlation, ecc.)
%         'rilbp'  : Local Binary Pattern rotation-invariant (TODO)
%         'avgedge': media del gradiente sull'oggetto
%
%     Default: {'hist', 'glcm', 'avgedge'}

  arguments
    img (:,:,3) uint8
    mask (:,:) logical
    options.texture_features cell = {'hist', 'glcm', 'avgedge'}
  end

  valid_features = {'hist', 'glcm', 'rilbp', 'avgedge'};
  if ~all(ismember(options.texture_features, valid_features))
    error('Valori non validi in options.texture_features. Ammessi: hist, glcm, rilbp, avgedge.');
  end

  % Conversione in scala di grigi
  if size(img, 3) ~= 1
    img = rgb2gray(img);
  end

  features = [];
  feature_names = {};

  if ismember('hist', options.texture_features)
    roi_pixels = double(img(mask));
    [hist_features, hist_feature_names] = compute_hist_stats_descriptors(roi_pixels);
    features = [features, hist_features];
    feature_names = [feature_names, hist_feature_names];
  end

  if ismember('glcm', options.texture_features)
    [glcm_features, glcm_feature_names] = compute_glcm_descriptors(img, mask);
    features = [features, glcm_features];
    feature_names = [feature_names, glcm_feature_names];
  end

  if ismember('rilbp', options.texture_features)
    %TODO: implementare LBP rotazione-invariante
    [rilbp_features, rilbp_feature_names] = compute_rilbp_features(img, mask);
    features = [features, rilbp_features];
    feature_names = [feature_names, rilbp_feature_names];
  end

  if ismember('avgedge', options.texture_features)
    avg_edge = compute_avg_edge(img, mask);
    features = [features, avg_edge];
    feature_names = [feature_names, {'texture.avg_edge'}];
  end

  % Costruzione della tabella
  texture_table = array2table(features, 'VariableNames', feature_names);
end


